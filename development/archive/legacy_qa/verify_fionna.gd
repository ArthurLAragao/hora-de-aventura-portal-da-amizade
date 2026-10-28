extends SceneTree
const Fionna = preload("res://scripts/characters/fionna_player.gd")
const Crank = preload("res://mechanisms/fionna_crank.gd")
const Platform = preload("res://mechanisms/fionna_platform.gd")
var room: Node2D
var fionna: Fionna
var finn: CoopPlayer
var block: PushBlock
var plate: PressurePlate
var gate: CoopGate
var crank: Crank
var platform: Platform
var role := 1
var signals_seen := 0
var checks: Array[Dictionary] = []
var failures := 0
var capture_dir := ""
var report_path := ""

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-dir="): capture_dir=arg.trim_prefix("--capture-dir=")
		if arg.begins_with("--report="): report_path=arg.trim_prefix("--report=")
	call_deferred("_run")

func _frames(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame

func _check(label: String, condition: bool) -> void:
	checks.append({"check":"Fionna P%d: %s"%[role,label],"passed":condition})
	print(("PASS " if condition else "FAIL ")+"Fionna P%d: %s"%[role,label])
	if not condition: failures+=1

func _release() -> void:
	for action in InputMap.get_actions():
		if String(action).begins_with("p1_") or String(action).begins_with("p2_"): Input.action_release(action)

func _bind() -> void:
	fionna=room.get_node("Fionna") as Fionna
	finn=room.get_node("Finn") as CoopPlayer
	block=room.get_node("PushBlock") as PushBlock
	plate=room.get_node("BlockPlate") as PressurePlate
	gate=room.get_node("BlockGate") as CoopGate
	crank=room.get_node("Crank") as Crank
	platform=room.get_node("ExtendPlatform") as Platform
	signals_seen=0
	crank.activated.connect(func(): signals_seen+=1)

func _fresh(slot: int) -> void:
	_release()
	if is_instance_valid(room):
		room.queue_free()
		await _frames(4)
	role=slot
	room=load("res://tests/fionna_test.tscn").instantiate()
	room.set("fionna_player_id",slot)
	root.add_child(room)
	current_scene=room
	_bind()
	await _frames(20)

func _place(actor: CoopPlayer, at: Vector2, settle: int=12) -> void:
	# Fixtures isolate collision and failure cases, never count as traversal.
	_release()
	actor.position=at
	actor.velocity=Vector2.ZERO
	await _frames(settle)

func _mine(suffix: String) -> String: return "p%d_%s"%[role,suffix]
func _other(suffix: String) -> String: return "p%d_%s"%[3-role,suffix]

func _tap(action: String, count: int=2) -> void:
	await process_frame
	Input.action_press(action)
	await _frames(count)
	Input.action_release(action)
	await _frames(3)

func _key(code: Key) -> void:
	var event:=InputEventKey.new()
	event.keycode=code
	event.pressed=true
	room._unhandled_key_input(event)
	await _frames(5)

func _until(predicate: Callable, limit: int=180) -> bool:
	for i in limit:
		if predicate.call(): return true
		await _frames(1)
	return predicate.call()

func _capture(name: String) -> void:
	if capture_dir.is_empty() or DisplayServer.get_name()=="headless": return
	DirAccess.make_dir_recursive_absolute(capture_dir)
	await RenderingServer.frame_post_draw
	_check("real render "+name,root.get_texture().get_image().save_png(capture_dir.path_join("p%d-%s.png"%[role,name]))==OK)

func _movement(slot: int) -> void:
	await _fresh(slot)
	_check("identity and abilities independent of player",fionna.character_id==&"fionna" and fionna.player_id==slot and finn.player_id==3-slot and fionna.has_ability(&"push") and fionna.has_ability(&"crank") and not fionna.has_ability(&"bridge"))
	_check("original visual reused without distortion",fionna.get_node("Visual").scene_file_path=="res://Assets/01_Characters/fionna/visual.tscn" and fionna.animated_sprite.sprite_frames.resource_path=="res://Assets/01_Characters/fionna/animations.tres" and fionna.animated_sprite.scale==Vector2.ONE and fionna.get_node("Visual").position==Vector2(0,32) and fionna.animated_sprite.position==Vector2(0,-32))
	var collider:=fionna.get_node("CollisionShape2D") as CollisionShape2D
	_check("human scale, collider and foot baseline aligned with Finn",(collider.shape as RectangleShape2D).size==Vector2(20,54) and collider.position.y+27==32 and absf(fionna.position.y-finn.position.y)<0.1)
	_check("grounded idle and original movement",fionna.is_on_floor() and fionna.animated_sprite.animation==&"idle" and fionna.speed==180 and fionna.jump_velocity==-360)
	await _capture("idle-scale")
	var start:=fionna.position.x
	await _tap(_other("left"),8)
	_check("partner input cannot move Fionna",absf(fionna.position.x-start)<0.1)
	await _frames(12)
	var partner:=finn.position.x
	Input.action_press(_mine("right"))
	await _frames(10)
	_check("right walk and separate controls",fionna.position.x>280 and fionna.animated_sprite.animation==&"walk" and not fionna.animated_sprite.flip_h and absf(finn.position.x-partner)<0.1)
	await _capture("walk")
	_release()
	await _tap(_mine("left"),8)
	_check("left-facing sprite",fionna.animated_sprite.flip_h)
	await _place(fionna,Vector2(280,465))
	Input.action_press(_mine("jump"))
	await _frames(1)
	Input.action_release(_mine("jump"))
	_check("jump_start does not block jump",fionna.velocity.y<-300 and fionna.animated_sprite.animation==&"jump_start")
	var clips: Array[StringName]=[]
	for i in 65:
		await _frames(1)
		if not clips.has(fionna.animated_sprite.animation):
			clips.append(fionna.animated_sprite.animation)
			if fionna.animated_sprite.animation in [&"jump",&"fall",&"land"]: await _capture(String(fionna.animated_sprite.animation))
	_check("ascent fall landing and idle actually observed",clips.has(&"jump") and clips.has(&"fall") and clips.has(&"land") and fionna.is_on_floor() and fionna.animated_sprite.animation==&"idle" and not fionna.movement_locked)
	await _place(fionna,Vector2(48,465))
	await _tap(_mine("left"),15)
	_check("left wall and floor collision",fionna.position.x>=41.8 and fionna.is_on_floor())
	await _place(fionna,Vector2(1090,330),40)
	await _tap(_mine("right"),15)
	_check("right wall collision",fionna.position.x<=1110.2 and fionna.is_on_floor())
	await _place(fionna,Vector2(160,465))
	Input.action_press(_mine("jump"))
	await _frames(1)
	Input.action_release(_mine("jump"))
	var ceiling:=false
	for i in 45:
		await _frames(1)
		ceiling=ceiling or fionna.is_on_ceiling()
	_check("ceiling stops ascent",ceiling and fionna.position.y>441)
	await _place(fionna,Vector2(832,330),40)
	_check("raised platform collision",fionna.is_on_floor() and fionna.position.y>389 and fionna.position.y<392)

func _push(slot: int) -> void:
	await _fresh(slot)
	await _tap(_mine("ability"),8)
	_check("no artificial Q/Shift action or push just from proximity",fionna.animated_sprite.animation==&"idle" and block.position.x==360)
	await _place(fionna,Vector2(488,465))
	_check("player alone cannot activate block plate",plate.overlaps_body(fionna) and not plate.is_active() and not gate.is_open)
	await _place(fionna,Vector2(256,465))
	var y:=block.position.y
	Input.action_press(_mine("right"))
	var saw_push:=false
	var reached:=false
	for i in 120:
		await _frames(1)
		saw_push=saw_push or fionna.animated_sprite.animation==&"push"
		if gate.is_open:
			reached=true
			break
	_check("actual movement pushes marked crate onto plate and opens door",reached and saw_push and plate.is_active() and block.position.x>430 and is_equal_approx(block.position.y,y))
	await _capture("push-plate")
	_release()
	await _frames(12)
	var stopped:=block.position
	await _frames(30)
	_check("release stops crate and push pose without jitter",block.position.distance_to(stopped)<0.01 and fionna.animated_sprite.animation==&"idle" and is_equal_approx(block.position.y,y))
	# Traverse from this genuine solution, including climbing the crate.
	Input.action_press(_mine("jump"))
	Input.action_press(_mine("right"))
	await _frames(2)
	Input.action_release(_mine("jump"))
	var traversed:=await _until(func(): return fionna.position.x>=640,160)
	_release()
	await _frames(15)
	_check("walk/jump from solved block through door without fixture placement",traversed and fionna.is_on_floor() and room.get("recovery_count")==0)
	await _tap(_mine("interact"))
	await _frames(12)
	await _capture("crank-normal-traversal")
	await _frames(88)
	_check("same traversal reaches and operates crank",crank.solved and platform.extended and signals_seen==1)
	# Climb the simple steps and walk over the extended support.
	Input.action_press(_mine("right"))
	await _until(func(): return fionna.position.x>=724,70)
	Input.action_release(_mine("right"))
	await _frames(5)
	for target in [768.0,832.0,896.0]:
		Input.action_press(_mine("jump"))
		Input.action_press(_mine("right"))
		await _frames(1)
		Input.action_release(_mine("jump"))
		await _until(func(): return fionna.position.x>=target,70)
		Input.action_release(_mine("right"))
		await _frames(40)
	_check("reaches passage by climbing test platforms",fionna.is_on_floor() and fionna.position.x>880 and fionna.position.y<352)
	Input.action_press(_mine("right"))
	var remained_grounded:=true
	for i in 55:
		await _frames(1)
		remained_grounded=remained_grounded and fionna.is_on_floor()
	_release()
	_check("extended passage walked across continuously without reset",fionna.position.x>1040 and fionna.is_on_floor() and remained_grounded and room.get("recovery_count")==0)
	await _capture("passage-crossed")
	await _fresh(slot)
	await _place(fionna,Vector2(420,465))
	Input.action_press(_mine("left"))
	await _frames(30)
	_check("leftward push uses contact and existing animation",block.position.x<320 and fionna.animated_sprite.animation==&"push" and fionna.animated_sprite.flip_h)
	await _capture("push-left")
	await _frames(60)
	var finn_collider:=finn.get_node("CollisionShape2D") as CollisionShape2D
	var finn_right:=finn.position.x+finn_collider.position.x+(finn_collider.shape as RectangleShape2D).size.x*0.5
	_check("crate also stops before the partner without pushing through him",block.position.x-29>=finn_right-0.2 and block.position.x<202 and absf(finn.position.x-160)<1.0)
	await _place(finn,Vector2(520,465))
	Input.action_press(_mine("left"))
	await _frames(90)
	_release()
	await _frames(15)
	_check("crate stops at left wall and cannot tunnel",block.position.x>=60.8 and block.position.x<62 and absf(block.position.y-y)<0.2 and fionna.animated_sprite.animation!=&"push")
	await _tap(_mine("reset"))
	_check("existing reset control restores nearby crate",block.position.distance_to(Vector2(360,474.35286))<0.1)
	await _fresh(slot)
	await _place(fionna,Vector2(100,465))
	fionna.process_mode=Node.PROCESS_MODE_DISABLED
	var non_pusher:=load("res://Assets/01_Characters/marceline/visual.tscn").instantiate() as CoopPlayer
	non_pusher.player_id=slot
	non_pusher.position=Vector2(318,465)
	room.add_child(non_pusher)
	await _frames(20)
	await _tap(_mine("right"),20)
	_check("real Marceline without push capability cannot move crate",not non_pusher.has_ability(&"push") and block.position.x==360)
	non_pusher.queue_free()
	await _frames(5)
	fionna.process_mode=Node.PROCESS_MODE_INHERIT
	await _place(finn,Vector2(317,465))
	Input.action_press(_other("right"))
	await _frames(15)
	_check("Finn is legitimately allowed to push same crate",block.position.x>375 and finn.animated_sprite.animation==&"push")
	Input.action_release(_other("right"))
	await _frames(12)
	var no_pull:=block.position.x
	await _tap(_other("left"),10)
	_check("moving away does not pull or carry crate",is_equal_approx(block.position.x,no_pull) and is_equal_approx(block.position.y,y))
	await _fresh(slot)
	block.position=Vector2(546,474.35286)
	await _place(fionna,Vector2(505,465))
	await _tap(_mine("right"),55)
	_check("closed gate physically stops crate; no false push animation",not gate.is_open and block.position.x<=547.1 and block.position.x>546 and fionna.animated_sprite.animation!=&"push")
	await _capture("blocked-by-door")
	await _fresh(slot)
	block.position=Vector2(1090,474.35286)
	await _place(fionna,Vector2(1048,465))
	await _tap(_mine("right"),50)
	_check("crate cannot cross right wall",block.position.x<=1091.1 and is_equal_approx(block.position.y,y))
	await _fresh(slot)
	block.position=Vector2(488,474.35286)
	await _frames(8)
	_check("plate accepts crate and changes texture",plate.is_active() and gate.is_open and plate.plate_sprite.texture.resource_path.ends_with("plate_down.png"))
	await _place(fionna,Vector2(425,465))
	await _tap(_mine("reset"))
	_check("reset releases plate but door stays permanently open",not plate.is_active() and gate.is_open and block.position.x==360 and plate.plate_sprite.texture.resource_path.ends_with("plate_up.png"))
	await _place(fionna,Vector2(360,380),40)
	var before:=block.position.x
	await _tap(_mine("right"),10)
	_check("walking on crate top does not push it",is_equal_approx(block.position.x,before) and fionna.animated_sprite.animation!=&"push")

func _crank(slot: int) -> void:
	await _fresh(slot)
	_check("crank refuses outside range",not crank.interact(fionna) and not platform.requested)
	await _place(finn,Vector2(660,465))
	_check("Finn really lacks crank capability and is refused",not finn.has_ability(&"crank") and crank.overlaps_body(finn) and not crank.interact(finn))
	await _place(fionna,Vector2(640,465))
	fionna.allowed_abilities.erase(&"crank")
	_check("identity alone cannot authorize crank",not crank.interact(fionna))
	fionna.allowed_abilities.append(&"crank")
	await _frames(3)
	_check("prompt uses owner role when both players in area",crank.overlaps_body(fionna) and crank.overlaps_body(finn) and crank.prompt.text.begins_with("E:" if slot==1 else "Enter:"))
	await _tap(_other("interact"))
	_check("other player's interaction cannot operate crank",not crank.pending and not platform.requested)
	await _tap(_mine("interact"))
	_check("own key begins original crank clip and only local lock",crank.pending and fionna.movement_locked and fionna.animated_sprite.animation==&"crank" and not finn.movement_locked and not platform.requested)
	await _frames(10)
	await _capture("crank-action")
	var x:=fionna.position.x
	var fx:=finn.position.x
	Input.action_press(_mine("right"))
	await _tap(_other("right"),6)
	_release()
	_check("partner remains controllable during crank",absf(fionna.position.x-x)<0.1 and finn.position.x>fx+10)
	await _key(KEY_ESCAPE)
	_check("cancel before completion leaves coherent retry state",not crank.pending and not crank.solved and not platform.requested and not fionna.movement_locked and fionna.interaction_owner==null and crank.sprite.animation==&"crank_0")
	await _tap(_mine("interact"))
	_check("repeat while busy is refused",crank.pending and not crank.interact(fionna) and signals_seen==0)
	await _frames(100)
	_check("natural finish extends support and restores motion",crank.solved and platform.extended and not fionna.movement_locked and fionna.interaction_owner==null and fionna.animated_sprite.animation==&"idle")
	_check("activation and signal remain idempotent",not crank.interact(fionna) and signals_seen==1 and crank.activation_count==1)
	_check("support surface matches original visual width and bank height",(platform.body_shape.shape as RectangleShape2D).size==Vector2(58,12) and absf(platform.position.x-960)<0.01 and absf(platform.position.y-382.35286)<0.01 and platform.get_node("Sprite2D").scale==Vector2.ONE and not platform.body_shape.disabled)
	await _capture("passage-extended")
	await _fresh(slot)
	await _place(fionna,Vector2(640,465))
	await _tap(_mine("interact"))
	fionna.animated_sprite.stop()
	await _frames(70)
	_check("stopped clip cancels safely without awarding passage",not fionna.movement_locked and not crank.pending and not crank.solved and not platform.requested)
	await _tap(_mine("right"),4)
	_check("control available after stopped clip",fionna.position.x>646)
	await _fresh(slot)
	await _place(fionna,Vector2(640,465))
	var original:=fionna.animated_sprite.sprite_frames
	fionna.animated_sprite.sprite_frames=original.duplicate()
	fionna.animated_sprite.sprite_frames.set_animation_loop(&"crank",true)
	await _tap(_mine("interact"))
	await _frames(70)
	_check("incorrect loop cannot keep controls locked",not fionna.movement_locked and not crank.solved and not platform.requested)
	fionna.animated_sprite.sprite_frames.set_animation_loop(&"crank",false)
	fionna.animated_sprite.sprite_frames.set_animation_speed(&"crank",0)
	await _tap(_mine("interact"))
	await _frames(135)
	_check("zero clip speed has bounded timeout",not fionna.movement_locked and not crank.solved)
	fionna.animated_sprite.sprite_frames.remove_animation(&"crank")
	_check("missing clip refuses action without taking controls",not crank.interact(fionna) and not fionna.movement_locked)
	fionna.animated_sprite.sprite_frames=original
	await _tap(_mine("interact"))
	await _frames(100)
	_check("valid clip can retry after cancellation failures",crank.solved and platform.extended and not fionna.movement_locked)
	await _fresh(slot)
	await _place(fionna,Vector2(640,465))
	await _tap(_mine("interact"))
	crank.queue_free()
	await _frames(10)
	_check("removing active mechanism restores controls without activation",not fionna.movement_locked and fionna.interaction_owner==null and not platform.requested)

func _platform_safety(slot: int) -> void:
	await _fresh(slot)
	await _place(fionna,Vector2(640,465))
	await _place(finn,Vector2(1010,350))
	await _tap(_mine("interact"))
	await _frames(100)
	_check("occupied path stops platform without moving or trapping Finn",crank.solved and platform.requested and platform.blocked and not platform.extended and platform.position.x>1000 and absf(finn.position.x-1010)<0.1 and not fionna.movement_locked and not finn.movement_locked)
	await _capture("platform-waiting")
	Input.action_press(_other("right"))
	await _until(func(): return finn.position.x>=1095,80)
	_release()
	await _frames(80)
	_check("platform resumes after player walks clear and stays extended",platform.extended and not platform.blocked and finn.position.x>1090 and finn.is_on_floor())
	await _frames(60)
	_check("permanent support does not retract or lose collider",platform.extended and platform.position.x==960 and not platform.body_shape.disabled)
	await _fresh(slot)
	await _place(fionna,Vector2(640,465))
	await _tap(_mine("interact"))
	await _until(func(): return platform.requested,80)
	# Collision fixture during travel, not a traversal or gameplay teleport.
	await _place(finn,Vector2(platform.position.x-35,350),2)
	await _frames(20)
	_check("player entering during extension cannot be swept through",platform.blocked and not platform.extended and absf(finn.position.x-(platform.position.x-35))<8)
	await _fresh(slot)
	# The block does not listen to E/Enter. Overlap its body and crank area.
	crank.position=Vector2(360,470)
	await _place(fionna,Vector2(318,465))
	var crate_start:=block.position
	await _tap(_mine("interact"))
	_check("one contextual press near block and crank starts only crank",crank.pending and fionna.movement_locked and block.position.distance_to(crate_start)<0.01)
	room.call("recover_pair")
	await _frames(15)
	_check("room recovery clears local action and leaves both visible",not crank.pending and not fionna.movement_locked and fionna.is_on_floor() and finn.is_on_floor() and fionna.visible and finn.visible)

func _restart(slot: int) -> void:
	await _fresh(slot)
	await _place(fionna,Vector2(640,465))
	await _tap(_mine("interact"))
	_check("restart fixture has active action",crank.pending)
	await _key(KEY_F2)
	await _frames(20)
	room=current_scene as Node2D
	_bind()
	_check("F2 during action clears locks and pending state",not crank.pending and not crank.solved and not fionna.movement_locked and not finn.movement_locked and not platform.requested and block.position.x==360)
	await _fresh(slot)
	block.position=Vector2(488,474.35286)
	await _place(fionna,Vector2(640,465))
	await _tap(_mine("interact"))
	await _frames(100)
	_check("restart fixture has both tests solved",gate.is_open and crank.solved and platform.extended)
	await _key(KEY_F2)
	await _frames(20)
	room=current_scene as Node2D
	_bind()
	_check("F2 after both tests restores saved clean state",not gate.is_open and not plate.is_active() and not crank.solved and not platform.extended and block.position.x==360 and not fionna.movement_locked)

func _run() -> void:
	root.size=Vector2i(1152,648)
	for slot in [1,2]:
		await _movement(slot)
		await _push(slot)
		await _crank(slot)
		await _platform_safety(slot)
		await _restart(slot)
	_release()
	room.queue_free()
	await _frames(5)
	if not report_path.is_empty(): FileAccess.open(report_path,FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"headless":DisplayServer.get_name()=="headless"},"\t"))
	print("Fionna checks: ",checks.size()," | failures: ",failures)
	quit(0 if failures==0 else 1)
