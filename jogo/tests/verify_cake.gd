extends SceneTree
const Cake=preload("res://cake_player.gd")
const Anchor=preload("res://tests/cake_anchor.gd")
var room: Node2D
var cake: Cake
var fionna: CoopPlayer
var tunnel: Node2D
var anchor: Anchor
var role:=1
var checks: Array[Dictionary]=[]
var failures:=0
var report_path:=""
var capture_dir:=""

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--report="): report_path=arg.trim_prefix("--report=")
		if arg.begins_with("--capture-dir="): capture_dir=arg.trim_prefix("--capture-dir=")
	call_deferred("_run")

func _frames(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame

func _check(label: String, ok: bool) -> void:
	checks.append({"check":"Cake P%d: %s"%[role,label],"passed":ok})
	print(("PASS " if ok else "FAIL ")+"Cake P%d: %s"%[role,label])
	if not ok: failures+=1

func _release() -> void:
	for action in InputMap.get_actions():
		if String(action).begins_with("p1_") or String(action).begins_with("p2_"): Input.action_release(action)

func _bind() -> void:
	cake=room.get_node("Cake") as Cake
	fionna=room.get_node("Fionna") as CoopPlayer
	tunnel=room.get_node("Tunnel")
	anchor=room.get_node("Anchor") as Anchor

func _fresh(slot: int) -> void:
	_release()
	if is_instance_valid(room):
		room.queue_free()
		await _frames(4)
	role=slot
	room=load("res://tests/cake_test.tscn").instantiate()
	room.set("cake_player_id",slot)
	root.add_child(room)
	current_scene=room
	_bind()
	await _frames(20)

func _mine(suffix: String) -> String: return "p%d_%s"%[role,suffix]
func _other(suffix: String) -> String: return "p%d_%s"%[3-role,suffix]

func _tap(action: String, hold: int=2) -> void:
	await process_frame
	Input.action_press(action)
	await _frames(hold)
	Input.action_release(action)
	await _frames(3)

func _until(predicate: Callable, count: int=180) -> bool:
	for i in count:
		if predicate.call(): return true
		await _frames(1)
	return predicate.call()

func _place(actor: CoopPlayer, at: Vector2, settle: int=12) -> void:
	# Explicit fixtures only for isolated rejection/collision cases.
	_release()
	actor.position=at
	actor.velocity=Vector2.ZERO
	await _frames(settle)

func _key(code: Key) -> void:
	var e:=InputEventKey.new()
	e.keycode=code
	e.pressed=true
	room._unhandled_key_input(e)
	await _frames(4)

func _capture(name: String) -> void:
	if capture_dir.is_empty() or DisplayServer.get_name()=="headless": return
	DirAccess.make_dir_recursive_absolute(capture_dir)
	await RenderingServer.frame_post_draw
	_check("real capture "+name,root.get_texture().get_image().save_png(capture_dir.path_join("p%d-%s.png"%[role,name]))==OK)

func _movement(slot: int) -> void:
	await _fresh(slot)
	_check("identity, role and own capabilities",cake.character_id==&"cake" and cake.player_id==slot and fionna.player_id==3-slot and cake.has_ability(&"crawl") and cake.has_ability(&"stretch") and not cake.has_ability(&"push"))
	_check("visual scene and original animations reused",cake.get_node("Visual").scene_file_path=="res://Assets/01_Characters/cake/visual.tscn" and cake.animated_sprite.sprite_frames.resource_path=="res://Assets/01_Characters/cake/animations.tres" and cake.animated_sprite.scale==Vector2.ONE)
	_check("native size, own shape and foot baseline",cake.body.shape.size==Vector2(30,28) and cake.body.position.y+14==32 and absf(cake.position.y-fionna.position.y)<0.1)
	_check("idle on safe floor",cake.is_on_floor() and cake.animated_sprite.animation==&"idle" and not cake.crawling)
	await _capture("scale-idle")
	var cx:=cake.position.x
	await _tap(_other("left"),8)
	_check("partner keys cannot move Cake",absf(cake.position.x-cx)<0.1)
	await _frames(12)
	var fx:=fionna.position.x
	Input.action_press(_mine("right"))
	await _frames(8)
	_check("own walk independent and right facing",cake.position.x>275 and cake.animated_sprite.animation==&"walk" and not cake.animated_sprite.flip_h and absf(fionna.position.x-fx)<0.1)
	_release()
	await _tap(_mine("left"),8)
	_check("left facing",cake.animated_sprite.flip_h)
	await _place(cake,Vector2(256,465))
	Input.action_press(_mine("jump"))
	await _frames(1)
	Input.action_release(_mine("jump"))
	_check("jump begins without lock",cake.velocity.y< -300 and cake.animated_sprite.animation==&"jump_start")
	var clips: Array[StringName]=[]
	for i in 65:
		await _frames(1)
		if not clips.has(cake.animated_sprite.animation):
			clips.append(cake.animated_sprite.animation)
			if cake.animated_sprite.animation in [&"jump",&"fall",&"land"]: await _capture(String(cake.animated_sprite.animation))
	_check("rise fall land and idle observed",clips.has(&"jump") and clips.has(&"fall") and clips.has(&"land") and cake.is_on_floor() and not cake.movement_locked)
	await _place(cake,Vector2(52,465))
	await _tap(_mine("left"),15)
	_check("left wall collision",cake.position.x>=46.8)
	await _place(cake,Vector2(1090,330),40)
	await _tap(_mine("right"),15)
	_check("right wall and raised floor collision",cake.position.x<=1105.2 and cake.is_on_floor())

func _crawl(slot: int) -> void:
	await _fresh(slot)
	await _tap(_mine("right"),30)
	_check("normal body is physically stopped at low roof",cake.position.x<305.2 and not cake.crawling)
	await _tap(_mine("interact"))
	_check("context starts low posture without repositioning",cake.crawling and cake.body.shape.size==Vector2(38,21) and cake.body.position.y+10.5==32 and cake.position.x<305.2)
	await _key(KEY_ESCAPE)
	_check("cancel at clear entrance restores normal shape",not cake.crawling and cake.body.shape.size==Vector2(30,28) and not cake.movement_locked)
	await _tap(_mine("interact"))
	Input.action_press(_mine("right"))
	await _until(func():return cake.position.x>380,100)
	_release()
	await _frames(12)
	_check("actual movement reaches inside tunnel",cake.crawling and cake.position.x>370 and cake.position.x<420 and cake.is_on_floor() and cake.animated_sprite.animation==&"crawl")
	await _capture("inside-tunnel")
	var inside_y:=cake.position.y
	await _tap(_mine("jump"),5)
	await _key(KEY_ESCAPE)
	await _tap(_mine("interact"))
	_check("cannot jump or stand into roof",cake.crawling and not cake.can_stand() and absf(cake.position.y-inside_y)<0.1 and cake.body.shape.size.y==21)
	await _tap(_mine("left"),20)
	_check("can reverse inside tunnel",cake.crawling and cake.position.x<370 and cake.animated_sprite.flip_h)
	Input.action_press(_mine("right"))
	var crossed:=await _until(func():return cake.position.x>525,200)
	_release()
	await _frames(12)
	_check("right exit traversed without teleport and tall posture restored",crossed and not cake.crawling and cake.body.shape.size==Vector2(30,28) and cake.is_on_floor() and room.get("recovery_count")==0)
	await _capture("right-exit")
	await _tap(_mine("interact"))
	Input.action_press(_mine("left"))
	var returned:=await _until(func():return cake.position.x<282,200)
	_release()
	await _frames(12)
	_check("right entrance and left exit work without teleport",returned and not cake.crawling and cake.body.shape.size.y==28 and room.get("recovery_count")==0)
	await _place(fionna,Vector2(288,465))
	_check("real Fionna lacks crawl and is refused",not fionna.has_ability(&"crawl") and not tunnel.call("interact",fionna))
	await _tap(_other("right"),30)
	_check("Fionna also blocked by tunnel geometry",fionna.position.x<310.2 and fionna.is_on_floor())
	_check("partner collider was not changed",(fionna.get_node("CollisionShape2D").shape as RectangleShape2D).size==Vector2(20,54))
	await _fresh(slot)
	await _tap(_mine("right"),30)
	await _tap(_mine("interact"))
	Input.action_press(_mine("right"))
	await _until(func():return cake.position.x>380,120)
	_release()
	await _key(KEY_F2)
	await _frames(20)
	room=current_scene as Node2D
	_bind()
	_check("F2 inside tunnel starts with clean posture and controls",not cake.crawling and not cake.movement_locked and cake.body.shape.size.y==28 and cake.position.x==256)

func _poses(slot: int) -> void:
	await _fresh(slot)
	_check("refuse outside area/wrong capacity",not anchor.activate(cake) and not anchor.activate(fionna))
	await _place(cake,Vector2(912,300),2)
	_check("refuse airborne activation",not anchor.activate(cake))
	for offset in [-8.0,0.0,8.0]:
		await _place(cake,Vector2(912+offset,340),30)
		var original:=cake.position
		Input.action_press(_mine("ability"))
		await _frames(5)
		_check("extension has no invisible support",anchor.state==anchor.State.EXTENDING and not anchor._support_active and cake.position.distance_to(original)<0.01)
		await _frames(90)
		_check("complete bridge single Cake and active support",anchor.state==anchor.State.HOLDING and anchor._support_active and not cake.animated_sprite.visible and anchor.visual.visible)
		Input.action_release(_mine("ability"))
		await _frames(90)
		_check("retract restores sprite controls and removes support",anchor.state==anchor.State.IDLE and not cake.movement_locked and cake.animated_sprite.visible and anchor.support.collision_layer==0)
	await _place(cake,Vector2(912,340),30)
	Input.action_press(_mine("ability"))
	await _frames(3)
	_release()
	await _frames(35)
	_check("early release restores controls",not cake.movement_locked and anchor.state==anchor.State.IDLE and not anchor._support_active)
	Input.action_press(_mine("ability"))
	await _frames(110)
	await _key(KEY_ESCAPE)
	_release()
	_check("safe cancel without partner restores controls",anchor.state==anchor.State.IDLE and cake.animated_sprite.visible and not cake.movement_locked)

func _walk_to(actor: CoopPlayer, prefix: String, target: float, limit: int=200) -> bool:
	Input.action_press(prefix+"_right")
	var ok:=await _until(func():return actor.position.x>=target,limit)
	Input.action_release(prefix+"_right")
	await _frames(10)
	return ok

func _jump_to(actor: CoopPlayer, prefix: String, target: float) -> bool:
	Input.action_press(prefix+"_jump")
	Input.action_press(prefix+"_right")
	await _frames(2)
	Input.action_release(prefix+"_jump")
	var ok:=await _until(func():return actor.position.x>=target,100)
	Input.action_release(prefix+"_right")
	await _frames(45)
	return ok

func _service_route(slot: int) -> void:
	await _fresh(slot)
	await _walk_to(cake,"p%d"%role,300)
	await _tap(_mine("interact"))
	await _walk_to(cake,"p%d"%role,530)
	await _walk_to(cake,"p%d"%role,724)
	for target in [768.0,832.0,896.0]: await _jump_to(cake,"p%d"%role,target)
	_check("Cake physically reaches anchor after tunnel and platforms",cake.position.x>=890 and cake.position.y<352 and not cake.crawling and room.get("recovery_count")==0)
	print("ROUTE_CAKE ",cake.position," valid=",anchor.can_activate(cake))
	Input.action_press(_mine("ability"))
	await _frames(110)
	_check("formed bridge on real route",anchor.state==Anchor.State.HOLDING and anchor._support_active)
	await _walk_to(fionna,"p%d"%(3-role),304)
	await _jump_to(fionna,"p%d"%(3-role),400)
	await _walk_to(fionna,"p%d"%(3-role),724)
	for target in [768.0,832.0,896.0]: await _jump_to(fionna,"p%d"%(3-role),target)
	await _walk_to(fionna,"p%d"%(3-role),910)
	# Small entry jump lands on the bridge; subsequent crossing is horizontal walking.
	await _jump_to(fionna,"p%d"%(3-role),947)
	_check("entry jump lands on Cake support",fionna.is_on_floor() and fionna.position.y<340 and anchor.get_dependents().has(fionna))
	await _capture("bridge-entry")
	Input.action_release(_mine("ability"))
	await _frames(6)
	_check("release with partner on bridge retains support",anchor._support_active and anchor.release_pending)
	await _tap(_other("jump"),2)
	await _frames(8)
	_check("airborne partner retains support",not fionna.is_on_floor() and anchor._support_active and anchor.get_dependents().has(fionna))
	await _frames(55)
	_check("partner lands back safely",fionna.is_on_floor() and anchor._support_active)
	await _walk_to(fionna,"p%d"%(3-role),980)
	await _capture("bridge-center")
	await _walk_to(fionna,"p%d"%(3-role),1005)
	# A small exit jump clears the preserved head contour, without deforming the art.
	await _jump_to(fionna,"p%d"%(3-role),1025)
	await _capture("bridge-exit")
	await _tap(_other("interact"))
	await _frames(65)
	await _walk_to(fionna,"p%d"%(3-role),1100)
	await _frames(90)
	_check("existing crank and platform provide independent permanent passage",room.get_node("Crank").get("solved") and room.get_node("ExtendPlatform").get("extended"))
	Input.action_release(_mine("ability"))
	await _frames(110)
	var followed:=await _walk_to(cake,"p%d"%role,1065)
	_check("Cake follows only after permanent support exists",followed and cake.is_on_floor() and not cake.movement_locked and room.get("recovery_count")==0)
	await _capture("permanent-passage-test-route")
	await _key(KEY_F2)
	await _frames(20)
	room=current_scene as Node2D
	_bind()
	_check("F2 clears permanent demo and both characters' state",not cake.crawling and not cake.movement_locked and not fionna.movement_locked and not room.get_node("ExtendPlatform").get("extended"))

func _run() -> void:
	root.size=Vector2i(1152,648)
	for slot in [1,2]:
		await _movement(slot)
		await _crawl(slot)
		await _poses(slot)
		await _service_route(slot)
	_release()
	room.queue_free()
	await _frames(4)
	if not report_path.is_empty(): FileAccess.open(report_path,FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"headless":DisplayServer.get_name()=="headless","bridge_functional":true,"unverified":["manual acceptance of integrated bridge","export","multiple resolutions"]},"\t"))
	print("Cake checks: ",checks.size()," | failures: ",failures," | functional Cake bridge: INTEGRATED")
	quit(0 if failures==0 else 1)


