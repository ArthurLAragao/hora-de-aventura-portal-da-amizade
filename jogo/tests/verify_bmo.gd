extends SceneTree
## Real engine/input/collision tests. Fixture placement does not count as playthrough.
const BMO = preload("res://bmo_player.gd")
const Terminal = preload("res://tests/bmo_terminal.gd")
var room: Node2D
var bmo: BMO
var marceline: CoopPlayer
var terminal: Terminal
var energy: Terminal
var gate: CoopGate
var role := 1
var failures := 0
var checks: Array[Dictionary] = []
var capture_dir := ""
var report_path := ""
var symbol_signals := 0
var energy_signals := 0

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-dir="): capture_dir = arg.trim_prefix("--capture-dir=")
		if arg.begins_with("--report="): report_path = arg.trim_prefix("--report=")
	call_deferred("_run")

func _frames(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame

func _check(label: String, value: bool) -> void:
	checks.append({"check":"BMO P%d: %s" % [role,label],"passed":value})
	print(("PASS " if value else "FAIL ")+"BMO P%d: %s" % [role,label])
	if not value: failures += 1

func _release() -> void:
	for action in InputMap.get_actions():
		if String(action).begins_with("p1_") or String(action).begins_with("p2_"): Input.action_release(action)

func _bind() -> void:
	bmo = room.get_node("BMO") as BMO
	marceline = room.get_node("Marceline") as CoopPlayer
	terminal = room.get_node("SymbolTerminal") as Terminal
	energy = room.get_node("EnergyTerminal") as Terminal
	gate = room.get_node("SymbolGate") as CoopGate
	symbol_signals = 0
	energy_signals = 0
	terminal.activated.connect(func(): symbol_signals += 1)
	energy.activated.connect(func(): energy_signals += 1)

func _fresh(slot: int, custom_sequence: Array[int] = []) -> void:
	_release()
	if is_instance_valid(room):
		room.queue_free()
		await _frames(4)
	role = slot
	room = load("res://tests/bmo_test.tscn").instantiate()
	room.set("bmo_player_id",slot)
	if not custom_sequence.is_empty(): room.set("symbol_sequence",custom_sequence)
	root.add_child(room)
	current_scene = room
	_bind()
	await _frames(20)

func _place(actor: CoopPlayer, at: Vector2, settle: int=12) -> void:
	_release()
	actor.position = at
	actor.velocity = Vector2.ZERO
	await _frames(settle)

func _tap(action: String, hold: int=2) -> void:
	await process_frame
	Input.action_press(action)
	await _frames(hold)
	Input.action_release(action)
	await _frames(3)

func _mine(suffix: String) -> String: return "p%d_%s" % [role,suffix]
func _other(suffix: String) -> String: return "p%d_%s" % [3-role,suffix]

func _capture(name: String) -> void:
	if capture_dir.is_empty() or DisplayServer.get_name() == "headless": return
	DirAccess.make_dir_recursive_absolute(capture_dir)
	await RenderingServer.frame_post_draw
	_check("real rendered capture "+name,root.get_texture().get_image().save_png(capture_dir.path_join("p%d-%s.png" % [role,name])) == OK)

func _key(code: Key) -> void:
	var key := InputEventKey.new()
	key.keycode = code
	key.pressed = true
	room._unhandled_key_input(key)
	await _frames(5)

func _select(value: int) -> void:
	for i in 3:
		if terminal.selection == value: return
		await _tap(_mine("right"))

func _solve() -> void:
	for symbol in terminal.sequence:
		await _select(symbol)
		await _tap(_mine("interact"))

func _movement(slot: int) -> void:
	await _fresh(slot)
	_check("identity/capabilities independent of role",bmo.character_id == &"bmo" and bmo.player_id == slot and marceline.player_id == 3-slot and bmo.has_ability(&"terminal") and bmo.has_ability(&"energy") and not bmo.has_ability(&"float") and not bmo.has_ability(&"bridge"))
	_check("visual scene reused, original resource and no distortion",bmo.get_node("Visual").scene_file_path == "res://Assets/01_Characters/bmo/visual.tscn" and bmo.animated_sprite.sprite_frames.resource_path == "res://Assets/01_Characters/bmo/animations.tres" and bmo.animated_sprite.scale == Vector2.ONE and bmo.animated_sprite.position == Vector2(0,-32) and bmo.get_node("Visual").position == Vector2(0,32))
	var shape := bmo.get_node("CollisionShape2D") as CollisionShape2D
	_check("BMO body has own proportions and shared foot baseline",(shape.shape as RectangleShape2D).size == Vector2(28,42) and shape.position.y+21 == 32 and bmo.is_on_floor() and absf(bmo.position.y-marceline.position.y)<0.1)
	_check("idle and unchanged movement values",bmo.animated_sprite.animation == &"idle" and bmo.speed == 180 and bmo.jump_velocity == -360)
	_check("instructions and contextual key match role",String(room.get_node("Instructions/Text").text).contains("BMO P%d"%slot) and terminal.prompt.text.begins_with("E:" if slot==1 else "Enter:"))
	await _capture("scale-idle")
	var bx := bmo.position.x
	await _tap(_other("left"),8)
	_check("partner input does not move BMO",absf(bmo.position.x-bx)<0.1)
	await _place(bmo,Vector2(280,465))
	var mx := marceline.position.x
	Input.action_press(_mine("right"))
	await _frames(10)
	_check("own input walks and leaves partner independent",bmo.position.x>305 and bmo.animated_sprite.animation==&"walk" and absf(marceline.position.x-mx)<0.1 and not bmo.animated_sprite.flip_h)
	await _capture("walk")
	_release()
	await _tap(_mine("left"),8)
	_check("left facing",bmo.animated_sprite.flip_h)
	await _place(bmo,Vector2(300,465))
	var takeoff_y := bmo.position.y
	Input.action_press(_mine("jump"))
	await _frames(1)
	Input.action_release(_mine("jump"))
	_check("jump_start moves immediately",bmo.velocity.y < -300 and bmo.animated_sprite.animation==&"jump_start")
	var clips: Array[StringName] = []
	var highest := bmo.position.y
	for i in 65:
		await _frames(1)
		highest = minf(highest,bmo.position.y)
		if not clips.has(bmo.animated_sprite.animation):
			clips.append(bmo.animated_sprite.animation)
			if bmo.animated_sprite.animation in [&"jump",&"fall",&"land"]: await _capture(String(bmo.animated_sprite.animation))
	_check("ascent fall landing clips observed and controls restored",clips.has(&"jump") and clips.has(&"fall") and clips.has(&"land") and bmo.is_on_floor() and bmo.animated_sprite.animation==&"idle" and not bmo.movement_locked)
	_check("existing jump strength, gravity and apex preserved",takeoff_y-highest>66 and takeoff_y-highest<71 and bmo.gravity==980)
	await _place(bmo,Vector2(48,465))
	await _tap(_mine("left"),15)
	_check("left wall and floor collision",bmo.position.x >= 45.8 and bmo.is_on_floor())
	await _place(bmo,Vector2(1090,465))
	await _tap(_mine("right"),15)
	_check("right wall collision",bmo.position.x <= 1106.2 and bmo.is_on_floor())
	await _place(bmo,Vector2(160,465))
	Input.action_press(_mine("jump"))
	await _frames(1)
	Input.action_release(_mine("jump"))
	var hit := false
	for i in 45:
		await _frames(1)
		hit = hit or bmo.is_on_ceiling()
	_check("ceiling blocks jump",hit and bmo.position.y>429)
	await _place(bmo,Vector2(448,340),45)
	_check("lands on raised platform",bmo.is_on_floor() and bmo.position.y>389 and bmo.position.y<392)

func _terminal(slot: int) -> void:
	await _fresh(slot)
	await _place(bmo,Vector2(800,465))
	_check("symbols refused outside range",not terminal.interact(bmo) and not terminal.panel_open)
	await _place(marceline,Vector2(224,465))
	_check("partner in range is refused by capability",terminal.overlaps_body(marceline) and not terminal.interact(marceline))
	await _place(bmo,Vector2(224,465))
	bmo.allowed_abilities.erase(&"terminal")
	_check("capability is required even for BMO",not terminal.interact(bmo))
	bmo.allowed_abilities.append(&"terminal")
	await _tap(_other("interact"))
	_check("partner interaction cannot open BMO panel",not terminal.panel_open)
	await _tap(_mine("ability"))
	_check("unused ability key does not operate terminals",not terminal.panel_open and not energy.pending)
	await process_frame
	Input.action_press(_mine("interact"))
	await _frames(10)
	_check("opening press held cannot enter first symbol",terminal.panel_open and terminal.entered.is_empty() and not terminal._armed and bmo.movement_locked and bmo.animated_sprite.animation == &"terminal")
	Input.action_release(_mine("interact"))
	await _frames(3)
	await _capture("panel-open")
	var pos := bmo.position
	await _tap(_mine("right"),8)
	_check("panel selection changes without moving BMO",terminal.selection==1 and bmo.position.distance_to(pos)<0.1)
	var selection := terminal.selection
	var partner_x := marceline.position.x
	await _tap(_other("right"),10)
	await _tap(_other("interact"))
	_check("partner moves while panel open; cannot select or confirm",marceline.position.x>partner_x+20 and terminal.selection==selection and terminal.entered.is_empty() and not marceline.movement_locked)
	await _key(KEY_ESCAPE)
	_check("Escape closes panel and clears local control lock",not terminal.panel_open and not bmo.movement_locked and bmo.interaction_owner==null and bmo.animation_override==&"")
	await _tap(_mine("right"),4)
	_check("movement available after cancel",bmo.position.x>pos.x+5)
	await _place(bmo,Vector2(224,465))
	await _tap(_mine("interact"))
	_check("reopening starts empty and selected circle",terminal.panel_open and terminal.selection==0 and terminal.entered.is_empty())
	for i in 3: await _tap(_mine("interact"))
	_check("wrong sequence gives retry without opening door",terminal.attempts==1 and not terminal.solved and not gate.is_open and terminal.entered.is_empty() and terminal.panel_open and terminal.feedback.text.contains("Tente"))
	await _capture("sequence-retry")
	# Check live partner access to the clue using jumps, without fixture teleport.
	await _place(marceline,Vector2(336,465))
	for target in [380.0,444.0,508.0,572.0]:
		Input.action_press(_other("jump"))
		Input.action_press(_other("right"))
		await _frames(1)
		Input.action_release(_other("jump"))
		for i in 60:
			if marceline.position.x>=target: break
			await _frames(1)
		Input.action_release(_other("right"))
		await _frames(40)
	_check("Marceline reaches elevated clue using movement/jumps while BMO operates",marceline.is_on_floor() and marceline.position.x>550 and marceline.position.y<312 and terminal.panel_open)
	await _capture("cooperation-clue")
	await _select(terminal.sequence[0])
	await _tap(_mine("interact"))
	_check("progress records first deliberate confirmation",terminal.entered.size()==1 and terminal.progress.text.contains("1/3"))
	await _capture("sequence-progress")
	for symbol in terminal.sequence.slice(1):
		await _select(symbol)
		await _tap(_mine("interact"))
	_check("correct sequence opens door once and closes panel",terminal.solved and gate.is_open and terminal.activation_count==1 and not terminal.panel_open and not bmo.movement_locked and terminal.attempts==2)
	_check("opened door collider disabled and visual feedback exists",gate.get_node("CollisionShape2D").disabled and terminal.status.text.contains("aberta"))
	_check("repeated terminal interaction and activation signal are idempotent",not terminal.interact(bmo) and terminal.activation_count==1 and symbol_signals==1)
	# Walk and jump through the room from the actual terminal, without resetting
	# position. This is distinct from collision fixtures used elsewhere.
	Input.action_press(_mine("right"))
	for i in 70:
		if bmo.position.x>=330: break
		await _frames(1)
	Input.action_release(_mine("right"))
	await _frames(6)
	for target in [380.0,444.0,508.0,572.0]:
		Input.action_press(_mine("jump"))
		Input.action_press(_mine("right"))
		await _frames(1)
		Input.action_release(_mine("jump"))
		for i in 60:
			if bmo.position.x>=target: break
			await _frames(1)
		Input.action_release(_mine("right"))
		await _frames(40)
	_check("BMO traverses platforms from terminal using real movement",bmo.is_on_floor() and bmo.position.x>550 and bmo.position.y<312)
	Input.action_press(_mine("right"))
	await _frames(65)
	_release()
	_check("room and opened door traversed without recovery or fixture reposition",bmo.position.x>740 and bmo.is_on_floor() and room.get("recovery_count")==0)
	await _capture("door-open")

func _energy(slot: int) -> void:
	await _fresh(slot)
	_check("energy rejected outside range",not energy.interact(bmo))
	await _place(marceline,Vector2(808,465))
	_check("Marceline cannot connect energy",energy.overlaps_body(marceline) and not energy.interact(marceline))
	await _place(bmo,Vector2(808,465))
	await _tap(_other("interact"))
	_check("partner key cannot connect energy",not energy.pending and not energy.energized)
	await _place(marceline,Vector2(920,465))
	await _tap(_mine("interact"))
	_check("contextual energy starts existing connect clip only",energy.pending and not energy.energized and not terminal.panel_open and bmo.movement_locked and bmo.animated_sprite.animation == &"connect_power")
	_check("repeating while pending has no extra effect",not energy.interact(bmo) and energy.activation_count==0)
	await _frames(12)
	await _capture("energy-action")
	await _frames(55)
	_check("connection completes once and restores normal controls",energy.energized and energy.activation_count==1 and not energy.pending and not bmo.movement_locked and bmo.interaction_owner==null and bmo.animated_sprite.animation==&"idle")
	_check("indicator, battery and status reflect success",room.get_node("EnergyIndicator").texture.resource_path.ends_with("receiver_on.png") and room.get_node("Battery").texture.resource_path.ends_with("battery_on.png") and energy.status.text.contains("conectada"))
	await _tap(_mine("interact"),12)
	_check("repeated energy interaction and activation signal are idempotent",energy.activation_count==1 and energy_signals==1 and not bmo.movement_locked)
	await _capture("energy-complete")
	await _fresh(slot)
	await _place(bmo,Vector2(808,465))
	await _tap(_mine("interact"))
	await _key(KEY_ESCAPE)
	_check("energy cancellation clears pending without activation",not energy.pending and not energy.energized and not bmo.movement_locked)
	await _tap(_mine("interact"))
	bmo.animated_sprite.stop()
	await _frames(65)
	_check("stopped non-ending clip watchdog restores controls and completes once",energy.energized and energy.activation_count==1 and not bmo.movement_locked and bmo.animated_sprite.animation==&"idle")
	await _fresh(slot)
	await _place(bmo,Vector2(808,465))
	var original := bmo.animated_sprite.sprite_frames
	bmo.animated_sprite.sprite_frames = original.duplicate()
	bmo.animated_sprite.sprite_frames.set_animation_loop(&"connect_power",true)
	await _tap(_mine("interact"))
	await _frames(65)
	_check("looping instead of finishing clip cannot trap control",not bmo.movement_locked and energy.energized and energy.activation_count==1)
	bmo.animated_sprite.sprite_frames = original

func _cleanup(slot: int) -> void:
	await _fresh(slot)
	await _tap(_mine("interact"))
	room.call("recover_pair")
	await _frames(15)
	_check("recovery clears panel and control lock",not bmo.movement_locked and not terminal.panel_open and bmo.interaction_owner==null and bmo.is_on_floor())
	await _tap(_mine("interact"))
	await _key(KEY_F2)
	await _frames(20)
	room=current_scene as Node2D
	_bind()
	_check("F2 during panel removes old UI and restores both controls",not bmo.movement_locked and not terminal.panel_open and terminal.entered.is_empty() and not marceline.movement_locked and not terminal.solved)
	await _fresh(slot)
	await _place(bmo,Vector2(808,465))
	await _tap(_mine("interact"))
	await _key(KEY_F2)
	await _frames(20)
	room=current_scene as Node2D
	_bind()
	_check("F2 during energy clears action, pending and indicator",not bmo.movement_locked and bmo.interaction_owner==null and not energy.pending and not energy.energized)
	await _fresh(slot)
	await _tap(_mine("interact"))
	await _solve()
	await _place(bmo,Vector2(808,465))
	await _tap(_mine("interact"))
	await _frames(65)
	await _key(KEY_F2)
	await _frames(20)
	room=current_scene as Node2D
	_bind()
	_check("F2 after solving both starts clean test and no stale lock",not terminal.solved and not energy.energized and not gate.is_open and not bmo.movement_locked and not marceline.movement_locked)
	await _fresh(slot)
	# Overlapping fixture ranges exercise the single dispatch, not scene layout.
	energy.position=terminal.position
	await _frames(5)
	await _tap(_mine("interact"))
	_check("one press with overlapping ranges starts exactly one interaction",terminal.panel_open != energy.pending)
	if terminal.panel_open:
		await _solve()
		_check("final confirmation cannot also start energy",terminal.solved and not energy.pending and not energy.energized)
	else:
		await _frames(65)
		_check("energy dispatch cannot also open symbols",energy.energized and not terminal.panel_open)
	await _fresh(slot)
	await _tap(_mine("interact"))
	terminal.queue_free()
	await _frames(8)
	_check("removing an active terminal restores owner controls",not bmo.movement_locked and bmo.interaction_owner==null)
	await _fresh(slot,[1,0,2])
	await _tap(_mine("interact"))
	await _solve()
	_check("Inspector sequence configuration is used by terminal and clue",terminal.sequence==[1,0,2] and terminal.solved and gate.is_open)

func _run() -> void:
	root.size=Vector2i(1152,648)
	for slot in [1,2]:
		await _movement(slot)
		await _terminal(slot)
		await _energy(slot)
		await _cleanup(slot)
	_release()
	room.queue_free()
	await _frames(4)
	if not report_path.is_empty():
		FileAccess.open(report_path,FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"headless":DisplayServer.get_name()=="headless"},"\t"))
	print("BMO checks: ",checks.size()," | failures: ",failures)
	quit(0 if failures==0 else 1)
