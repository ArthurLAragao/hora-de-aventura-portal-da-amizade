extends SceneTree

const MarcelineController = preload("res://marceline_player.gd")
const MusicMechanism = preload("res://tests/music_test_mechanism.gd")
var failures := 0
var checks: Array[Dictionary] = []
var room: Node2D
var marceline: MarcelineController
var reference: CoopPlayer
var mechanism: MusicMechanism
var gate: CoopGate
var role := 1
var capture_dir := ""
var report_path := ""

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="): capture_dir=argument.trim_prefix("--capture-dir=")
		if argument.begins_with("--report="): report_path=argument.trim_prefix("--report=")
	call_deferred("_run")

func _frames(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame

func _until(predicate: Callable, limit: int=180) -> bool:
	for i in limit:
		if predicate.call(): return true
		await _frames(1)
	return predicate.call()

func _check(label: String, condition: bool) -> void:
	checks.append({"check":label,"passed":condition})
	print(("PASS " if condition else "FAIL ")+label)
	if not condition: failures+=1

func _prefix() -> String: return "p%d"%role
func _other() -> String: return "p%d"%(3-role)
func _tag() -> String: return "Marceline P%d: "%role

func _release() -> void:
	for action in InputMap.get_actions():
		if String(action).begins_with("p1_") or String(action).begins_with("p2_"): Input.action_release(action)

func _bind() -> void:
	marceline=room.get_node("Marceline") as MarcelineController
	reference=room.get_node("Finn") as CoopPlayer
	mechanism=room.get_node("MusicPanel") as MusicMechanism
	gate=room.get_node("MusicGate") as CoopGate

func _fresh(slot: int) -> void:
	_release()
	if is_instance_valid(room):
		room.queue_free()
		await _frames(4)
	role=slot
	room=load("res://tests/marceline_test.tscn").instantiate()
	room.set("marceline_player_id",slot)
	root.add_child(room)
	current_scene=room
	_bind()
	await _frames(20)

func _place(player: CoopPlayer, position: Vector2, wait: int=12) -> void:
	# Fixtures only isolate character state; no puzzle progression is claimed.
	player.position=position
	player.velocity=Vector2.ZERO
	await _frames(wait)

func _air(position: Vector2) -> void:
	await _place(marceline,Vector2(160,245))
	await _place(marceline,position,2)
	marceline.velocity.y=100

func _capture(name: String) -> void:
	if capture_dir.is_empty() or DisplayServer.get_name()=="headless": return
	DirAccess.make_dir_recursive_absolute(capture_dir)
	await RenderingServer.frame_post_draw
	_check("real capture "+name,root.get_texture().get_image().save_png(capture_dir.path_join(name+".png"))==OK)

func _movement(slot: int) -> void:
	await _fresh(slot)
	_check(_tag()+"identity, abilities and controls independent",marceline.character_id==&"marceline" and marceline.player_id==slot and int(marceline.get_meta("player_id"))==slot and marceline.has_ability(&"float") and marceline.has_ability(&"music") and not marceline.has_ability(&"push") and not marceline.has_ability(&"bridge"))
	_check(_tag()+"original animation resource and complete clips",marceline.animated_sprite.sprite_frames.resource_path=="res://Assets/01_Characters/marceline/animations.tres" and marceline.animated_sprite.sprite_frames.get_frame_count(&"float")==6 and marceline.animated_sprite.sprite_frames.get_frame_count(&"play_music")==9 and marceline.animated_sprite.sprite_frames.get_frame_count(&"walk")==8)
	var collider:=marceline.get_node("CollisionShape2D") as CollisionShape2D
	_check(_tag()+"uniform scale, aligned feet and usable collider",marceline.animated_sprite.scale==Vector2.ONE and marceline.animated_sprite.position==Vector2.ZERO and (collider.shape as RectangleShape2D).size==Vector2(22,54) and is_equal_approx(collider.position.y+27,32) and absf(marceline.position.y-reference.position.y)<0.1)
	_check(_tag()+"ground idle and full landing charge",marceline.is_on_floor() and marceline.animated_sprite.animation==&"idle" and is_equal_approx(marceline.float_remaining,1.0) and not marceline.is_floating)
	_check(_tag()+"test controls describe selected role",String(room.get_node("Instructions/Text").text).contains("P%d"%slot) and String(room.get_node("Instructions/Text").text).contains("Q: flutuar" if slot==1 else "Shift direito: flutuar"))
	await _capture("p%d-idle-scale"%role)
	var old_reference:=reference.position.x
	Input.action_press(_prefix()+"_right")
	await _frames(12)
	Input.action_release(_prefix()+"_right")
	_check(_tag()+"walk right moves only Marceline",marceline.position.x>190 and absf(reference.position.x-old_reference)<0.1 and marceline.animated_sprite.animation==&"walk" and not marceline.animated_sprite.flip_h)
	await _capture("p%d-walk"%role)
	Input.action_press(_prefix()+"_left")
	await _frames(10)
	Input.action_release(_prefix()+"_left")
	_check(_tag()+"sprite faces left",marceline.animated_sprite.flip_h)
	await _frames(12)
	var old_mc:=marceline.position.x
	Input.action_press(_other()+"_right")
	await _frames(6)
	Input.action_release(_other()+"_right")
	_check(_tag()+"other slot moves reference only",reference.position.x>old_reference+10 and absf(marceline.position.x-old_mc)<0.1)
	await _place(marceline,Vector2(160,245))
	Input.action_press(_prefix()+"_jump")
	await _frames(1)
	Input.action_release(_prefix()+"_jump")
	_check(_tag()+"jump_start does not delay upward movement",marceline.velocity.y < -300 and marceline.animated_sprite.animation==&"jump_start")
	var clips: Array[StringName]=[]
	var min_y:=marceline.position.y
	for frame in 65:
		await _frames(1)
		min_y=minf(min_y,marceline.position.y)
		if not clips.has(marceline.animated_sprite.animation):
			clips.append(marceline.animated_sprite.animation)
			if marceline.animated_sprite.animation in [&"jump",&"fall",&"land"]:
				await _capture("p%d-%s"%[role,String(marceline.animated_sprite.animation)])
	_check(_tag()+"jump ascent, fall and land clips really occur",clips.has(&"jump") and clips.has(&"fall") and clips.has(&"land"))
	_check(_tag()+"existing jump strength and free idle after landing",min_y>180 and min_y<190 and marceline.is_on_floor() and marceline.animated_sprite.animation==&"idle" and not marceline.movement_locked)
	# The float key during ascent preserves this same apex; it never adds lift.
	Input.action_press(_prefix()+"_ability")
	await _frames(8)
	_check(_tag()+"ability on ground cannot start or consume float",not marceline.is_floating and is_equal_approx(marceline.float_remaining,1.0) and not mechanism.activated)
	Input.action_press(_prefix()+"_jump")
	await _frames(1)
	Input.action_release(_prefix()+"_jump")
	var float_min:=marceline.position.y
	while marceline.velocity.y<0:
		await _frames(1)
		float_min=minf(float_min,marceline.position.y)
	_check(_tag()+"holding float cannot increase jump height",absf(float_min-min_y)<0.2)
	_release()
	await _frames(100)
	await _place(marceline,Vector2(48,520))
	Input.action_press(_prefix()+"_left")
	await _frames(15)
	Input.action_release(_prefix()+"_left")
	_check(_tag()+"left wall and safe floor collide",marceline.position.x>=42.8 and marceline.is_on_floor())
	await _place(marceline,Vector2(1090,520))
	Input.action_press(_prefix()+"_right")
	await _frames(15)
	Input.action_release(_prefix()+"_right")
	_check(_tag()+"right wall collides",marceline.position.x<=1109.2 and marceline.is_on_floor())
	await _place(marceline,Vector2(304,245))
	Input.action_press(_prefix()+"_jump")
	await _frames(1)
	Input.action_release(_prefix()+"_jump")
	var hit_ceiling:=false
	for frame in 30:
		await _frames(1)
		hit_ceiling=hit_ceiling or marceline.is_on_ceiling()
	_check(_tag()+"jump hits existing-tile ceiling without crossing",hit_ceiling and marceline.position.y>225)
	await _place(marceline,Vector2(640,400),40)
	_check(_tag()+"lands on raised platform",marceline.is_on_floor() and marceline.position.y>449 and marceline.position.y<452)

func _floating(slot: int) -> void:
	await _fresh(slot)
	await _air(Vector2(416,160))
	Input.action_press(_other()+"_ability")
	await _frames(2)
	Input.action_release(_other()+"_ability")
	_check(_tag()+"other player's ability does not activate float",not marceline.is_floating)
	var start_y:=marceline.position.y
	Input.action_press(_prefix()+"_ability")
	await _frames(12)
	_check(_tag()+"float uses own key, slows descent and existing animation",marceline.is_floating and marceline.velocity.y>0 and marceline.velocity.y<=45.01 and marceline.position.y>=start_y and marceline.animated_sprite.animation==&"float" and marceline.float_remaining<0.85 and not mechanism.activated)
	await _capture("p%d-float"%role)
	var remaining:=marceline.float_remaining
	Input.action_release(_prefix()+"_ability")
	await _frames(3)
	_check(_tag()+"release ends float immediately without restoring charge",not marceline.is_floating and marceline.velocity.y>45 and is_equal_approx(marceline.float_remaining,remaining))
	Input.action_press(_prefix()+"_ability")
	await _frames(2)
	_check(_tag()+"repress uses remaining charge, not a fresh duration",marceline.is_floating and marceline.float_remaining<remaining and marceline.float_remaining<0.85)
	# Recovery is the isolated room's existing restoration route, not a phase edit.
	room.call("recover_pair")
	_check(_tag()+"recovery clears ability and action state immediately",not marceline.is_floating and marceline.float_remaining==0 and not marceline.movement_locked and marceline._interaction_left==0)
	_release()
	await _frames(20)
	_check(_tag()+"recovered character lands normally and recharges",marceline.is_on_floor() and is_equal_approx(marceline.float_remaining,1.0) and marceline.animated_sprite.animation==&"idle")
	await _air(Vector2(416,-1000))
	var no_refill:=true
	var previous:=marceline.float_remaining
	for pulse in 10:
		Input.action_press(_prefix()+"_ability")
		await _frames(2)
		Input.action_release(_prefix()+"_ability")
		await _frames(2)
		no_refill=no_refill and marceline.float_remaining<=previous
		previous=marceline.float_remaining
	Input.action_press(_prefix()+"_ability")
	await _frames(70)
	_check(_tag()+"repeated presses cannot renew airtime budget",no_refill and marceline.float_remaining==0 and not marceline.is_floating and not marceline.is_on_floor())
	_check(_tag()+"duration expires and normal gravity resumes",marceline.velocity.y>45 and marceline.animated_sprite.animation==&"fall")
	Input.action_release(_prefix()+"_ability")
	await _frames(1)
	Input.action_press(_prefix()+"_ability")
	await _frames(3)
	_check(_tag()+"exhausted charge cannot restart midair",marceline.float_remaining==0 and not marceline.is_floating)
	_release()
	await _until(func():return marceline.is_on_floor(),180)
	_check(_tag()+"only landing restores full charge",marceline.is_on_floor() and is_equal_approx(marceline.float_remaining,marceline.float_duration))
	await _air(Vector2(1090,150))
	Input.action_press(_prefix()+"_ability")
	Input.action_press(_prefix()+"_right")
	await _frames(12)
	_check(_tag()+"float still collides with the wall",marceline.is_floating and marceline.position.x<=1109.2 and marceline.velocity.y<=45.01)
	_release()
	await _air(Vector2(416,500))
	Input.action_press(_prefix()+"_ability")
	await _until(func():return marceline.is_on_floor(),100)
	_check(_tag()+"active float lands on floor, ends and refills",marceline.is_on_floor() and not marceline.is_floating and is_equal_approx(marceline.float_remaining,1.0))
	_release()
	await _air(Vector2(416,160))
	marceline.allowed_abilities.erase(&"float")
	Input.action_press(_prefix()+"_ability")
	await _frames(3)
	_check(_tag()+"float requires character capability",not marceline.is_floating)
	_release()
	marceline.allowed_abilities.append(&"float")
	await _place(marceline,Vector2(304,245))
	Input.action_press(_prefix()+"_ability")
	Input.action_press(_prefix()+"_jump")
	await _frames(1)
	Input.action_release(_prefix()+"_jump")
	var blocked:=false
	for frame in 45:
		await _frames(1)
		blocked=blocked or marceline.is_on_ceiling()
	_check(_tag()+"floating cannot pass the ceiling",blocked and marceline.position.y>=227)
	_release()

func _music(slot: int) -> void:
	await _fresh(slot)
	Input.action_press(_prefix()+"_interact")
	await _frames(3)
	Input.action_release(_prefix()+"_interact")
	_check(_tag()+"music is refused outside range",not mechanism.activated and not mechanism.activate(marceline) and not gate.is_open)
	await _place(reference,Vector2(912,520))
	Input.action_press(_other()+"_interact")
	await _frames(3)
	Input.action_release(_other()+"_interact")
	_check(_tag()+"Finn cannot activate music even in range",mechanism.overlaps_body(reference) and not mechanism.activate(reference) and not mechanism.activated)
	await _place(reference,Vector2(780,520))
	await _place(marceline,Vector2(856,520))
	marceline.allowed_abilities.erase(&"music")
	_check(_tag()+"music authorization is capability based",not mechanism.activate(marceline))
	marceline.allowed_abilities.append(&"music")
	Input.action_press(_other()+"_interact")
	await _frames(3)
	Input.action_release(_other()+"_interact")
	_check(_tag()+"other slot cannot trigger Marceline interaction",not mechanism.activated)
	Input.action_press(_prefix()+"_ability")
	await _frames(8)
	Input.action_release(_prefix()+"_ability")
	_check(_tag()+"ability key does not also perform music",not mechanism.activated and marceline.animated_sprite.animation!=&"play_music")
	await process_frame
	Input.action_press(_prefix()+"_interact")
	await process_frame
	# Same frame dispatch as a real key; the node's normal _process handles input.
	if Input.is_action_just_pressed(_prefix()+"_interact"): mechanism._process(1.0/60.0)
	await _frames(3)
	Input.action_release(_prefix()+"_interact")
	_check(_tag()+"own interaction opens door and begins real music clip",mechanism.activated and gate.is_open and marceline.animated_sprite.animation==&"play_music" and not marceline.is_floating and not marceline.movement_locked)
	await _frames(8)
	await _capture("p%d-music"%role)
	var old_x:=marceline.position.x
	Input.action_press(_prefix()+"_right")
	await _frames(4)
	Input.action_release(_prefix()+"_right")
	_check(_tag()+"music pose survives idle/walk update without locking controls",marceline.position.x>old_x+5 and marceline.animated_sprite.animation==&"play_music")
	await _frames(65)
	_check(_tag()+"music ends naturally and normal idle returns",marceline.animated_sprite.animation==&"idle" and marceline._interaction_left==0 and not marceline.movement_locked)
	_check(_tag()+"visual feedback and door collision update",String(mechanism.status.text).contains("ATIVADO") and gate.get_node("CollisionShape2D").disabled and gate.get_node("Sprite2D").texture.resource_path.ends_with("musical_door_open.png"))
	await _capture("p%d-music-complete"%role)
	_check(_tag()+"solved mechanism cannot replay false music",not mechanism.activate(marceline))
	Input.action_press(_prefix()+"_right")
	var crossed:=await _until(func():return marceline.position.x>1070,180)
	Input.action_release(_prefix()+"_right")
	await _frames(12)
	_check(_tag()+"opened musical door is physically passable",crossed and marceline.is_on_floor())
	_check(_tag()+"music can start for interruption test",marceline.play_music_interaction())
	marceline.animated_sprite.stop()
	await _frames(65)
	_check(_tag()+"timeout releases stopped music animation",marceline._interaction_left==0 and marceline.animated_sprite.animation==&"idle" and not marceline.movement_locked)
	marceline.play_music_interaction()
	Input.action_press(_prefix()+"_jump")
	await _frames(1)
	Input.action_release(_prefix()+"_jump")
	_check(_tag()+"jump can interrupt music and retains control",marceline.velocity.y<0 and marceline._interaction_left==0 and marceline.animated_sprite.animation==&"jump_start")
	await _fresh(slot)
	_check(_tag()+"new test instance starts with clean states",not marceline.is_floating and is_equal_approx(marceline.float_remaining,1.0) and not mechanism.activated and not gate.is_open and marceline._interaction_left==0)

func _restart_key() -> void:
	await _fresh(1)
	await _air(Vector2(416,160))
	Input.action_press("p1_ability")
	await _frames(4)
	var old_id:=room.get_instance_id()
	var key:=InputEventKey.new()
	key.keycode=KEY_F2
	key.pressed=true
	room._unhandled_key_input(key)
	_release()
	await _frames(20)
	room=current_scene as Node2D
	_bind()
	_check("F2 actually reloads scene and clears float/music/door",room.get_instance_id()!=old_id and not marceline.is_floating and is_equal_approx(marceline.float_remaining,1.0) and not mechanism.activated and not gate.is_open and marceline.animated_sprite.animation==&"idle")

func _run() -> void:
	root.size=Vector2i(1152,648)
	for slot in [1,2]:
		await _movement(slot)
		await _floating(slot)
		await _music(slot)
	await _restart_key()
	_release()
	room.queue_free()
	await _frames(4)
	if not report_path.is_empty():
		FileAccess.open(report_path,FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"headless":DisplayServer.get_name()=="headless"},"\t"))
	print("Marceline checks: ",checks.size()," | failures: ",failures)
	quit(0 if failures==0 else 1)
