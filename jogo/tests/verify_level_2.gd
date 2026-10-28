extends SceneTree
var room: Node2D
var cake: CoopPlayer
var fionna: CoopPlayer
var role:=1
var failures:=0
var checks: Array[Dictionary]=[]
var capture_dir:=""
var report_path:=""
func _initialize() -> void:
	if DisplayServer.get_name()!="headless": DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--report="): report_path=arg.trim_prefix("--report=")
		if arg.begins_with("--capture-dir="): capture_dir=arg.trim_prefix("--capture-dir=")
	call_deferred("run")
func frames(n: int) -> void:
	for i in n:
		await physics_frame
		await process_frame
func check(label: String,ok: bool) -> void:
	checks.append({"check":"Cake P%d: %s"%[role,label],"passed":ok})
	print(("PASS " if ok else "FAIL ")+"Cake P%d: "%role+label)
	if not ok: failures+=1
func release() -> void:
	for a in InputMap.get_actions():
		if String(a).begins_with("p1_") or String(a).begins_with("p2_"): Input.action_release(a)
func until(predicate: Callable,count: int=240) -> bool:
	for i in count:
		if predicate.call(): return true
		await frames(1)
	return predicate.call()
func fresh(slot: int,start: int=0) -> void:
	release()
	if is_instance_valid(room):
		room.queue_free()
		await frames(4)
	role=slot
	room=load("res://level_2.tscn").instantiate()
	room.cake_player_id=slot
	room.test_start=start
	root.add_child(room)
	current_scene=room
	cake=room.get_node("Cake")
	fionna=room.get_node("Fionna")
	await frames(20)
func action(actor: CoopPlayer,suffix: String) -> String:
	return "p%d_%s"%[actor.player_id,suffix]
func tap(actor: CoopPlayer,suffix: String,n: int=2) -> void:
	await process_frame
	Input.action_press(action(actor,suffix))
	await frames(n)
	Input.action_release(action(actor,suffix))
	await frames(3)
func walk(actor: CoopPlayer,target: float,limit: int=260) -> bool:
	var right:=actor.position.x<target
	var key:=action(actor,"right" if right else "left")
	Input.action_press(key)
	var reached:=await until(func(): return actor.position.x>=target if right else actor.position.x<=target,limit)
	Input.action_release(key)
	await frames(10)
	return reached
func jump(actor: CoopPlayer,target: float) -> bool:
	Input.action_press(action(actor,"jump"))
	Input.action_press(action(actor,"right"))
	await frames(2)
	Input.action_release(action(actor,"jump"))
	var reached:=await until(func(): return actor.position.x>=target,100)
	Input.action_release(action(actor,"right"))
	await frames(45)
	return reached
func capture(label: String) -> void:
	if capture_dir.is_empty() or DisplayServer.get_name()=="headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(capture_dir.path_join("level2-p%d-%s.png"%[role,label]))
func has_clear_body(actor: CoopPlayer) -> bool:
	var collider:=actor.get_node("CollisionShape2D") as CollisionShape2D
	var probe:=RectangleShape2D.new()
	probe.size=collider.shape.size-Vector2(0.3,0.3)
	var query:=PhysicsShapeQueryParameters2D.new()
	query.shape=probe
	query.transform=collider.global_transform
	query.collision_mask=1
	return actor.get_world_2d().direct_space_state.intersect_shape(query,1).is_empty()
func route(slot: int) -> void:
	await fresh(slot)
	check("safe separate spawns/roles/own ice grid",cake.is_on_floor() and fionna.is_on_floor() and cake.position.distance_to(fionna.position)>40 and cake.player_id==slot and fionna.player_id==3-slot and room.get_node("Terrain").tile_set.tile_size==Vector2i(32,32))
	var cam:=room.get_node("SharedCamera") as SharedCamera
	check("shared camera references and own bounds",cam.player_a==fionna and cam.player_b==cake and cam.limit_right==2304 and cam.limit_bottom==648)
	await capture("start")
	var partner_x:=cake.position.x
	await walk(fionna,290)
	check("independent input and marked block can move",cake.position.x==partner_x and fionna.position.x>260)
	var block: PushBlock=room.get_node("PushBlock")
	var bx:=block.position.x
	Input.action_press(action(fionna,"right"))
	await until(func(): return block.position.x>=360,110)
	Input.action_release(action(fionna,"right"))
	await frames(15)
	check("actual horizontal block push stops",block.position.x>bx+20 and fionna.is_on_floor())
	var stopped:=block.position.x
	await frames(12)
	check("block has no drift after push",absf(block.position.x-stopped)<0.1)
	await walk(cake,280)
	await jump(cake,402)
	await walk(cake,420)
	await tap(cake,"interact")
	check("context begins crawl at real entrance",cake.get("crawling"))
	await walk(cake,530)
	check("tunnel actually traversed and cannot stand under roof",cake.position.x>510 and cake.get("crawling") and not cake.call("can_stand"))
	await tap(cake,"jump")
	check("low roof prevents jumping",cake.get("crawling") and cake.is_on_floor())
	await walk(cake,484)
	check("real reverse in tunnel",cake.position.x<490 and cake.get("crawling"))
	await walk(cake,644)
	check("exit restores normal posture",not cake.get("crawling") and cake.is_on_floor() and room.tunnel_visited)
	await tap(cake,"interact")
	await frames(4)
	check("Cake switch legitimately unlocks first crank",room.first_unlocked and room.first_crank.monitoring)
	await capture("tunnel-switch")
	await jump(fionna,block.position.x)
	check("Fionna uses the actual ice block as step",fionna.is_on_floor() and fionna.position.y<445)
	await jump(fionna,480)
	check("Fionna reaches top route instead of being trapped",fionna.is_on_floor() and fionna.position.y<410)
	await walk(fionna,744)
	await tap(fionna,"interact")
	await frames(65)
	await walk(fionna,710)
	await frames(100)
	check("first crank extends permanent ice passage",room.first_crank.solved and room.get_node("FirstPlatform").extended)
	await walk(cake,1000)
	check("Fionna traverses the stepped ice ridge",await ridge(fionna))
	check("Cake traverses the same ridge",await ridge(cake))
	await walk(cake,1475)
	await frames(15)
	check("both pass first section without recovery",room.recovery_count==0 and cake.is_on_floor() and room.anchor.can_activate(cake))
	Input.action_press(action(cake,"ability"))
	await frames(110)
	check("Cake bridge works at translated level anchor",room.anchor._support_active and room.anchor.state==room.anchor.State.HOLDING)
	await walk(fionna,1475)
	await jump(fionna,1520)
	check("entry lands on Cake, not bypass jump",fionna.is_on_floor() and fionna.position.y<480 and room.anchor.get_dependents().has(fionna))
	await capture("bridge")
	Input.action_release(action(cake,"ability"))
	await tap(fionna,"jump")
	await frames(8)
	check("airborne release waits safely in this level",room.anchor._support_active and not fionna.is_on_floor())
	await frames(55)
	await walk(fionna,1560)
	await jump(fionna,1620)
	await tap(fionna,"interact")
	await frames(70)
	await walk(fionna,1730)
	await frames(100)
	check("second permanent passage available and Cake released",room.crank.solved and room.get_node("ExtendPlatform").extended and not cake.movement_locked and cake.animated_sprite.visible and not room.anchor._support_active)
	await walk(cake,1760)
	check("pair reunites without teleport or fall recovery",cake.is_on_floor() and fionna.is_on_floor() and room.recovery_count==0)
	await walk(fionna,1984)
	await capture("crystal-terrace")
	check("Fionna reaches the crystal terrace",await jump(fionna,2056))
	await walk(fionna,2190)
	await walk(cake,1984)
	check("Cake reaches the crystal terrace",await jump(cake,2056))
	await walk(cake,2150)
	Input.action_press(action(cake,"right"))
	await until(func():return room.completed,120)
	Input.action_release(action(cake,"right"))
	check("normal route reaches reserved final area",cake.position.x>2100 and fionna.position.x>2100 and room.recovery_count==0 and room.completed)
	check("crystal and joint exit complete once",room.crystal_collected and room.completion_count==1 and room.final_exit._completed)
	await capture("final")
	check("one composed scenery layer",room.has_node("RegionalScenery/RegionalComposition") and room.get_node_or_null("IceScenery")==null)
	var key:=InputEventKey.new()
	key.pressed=true
	key.keycode=KEY_F2
	room._unhandled_key_input(key)
	await frames(25)
	room=current_scene
	cake=room.get_node("Cake")
	fionna=room.get_node("Fionna")
	check("F2 resets controls, bridge and mechanisms",not cake.movement_locked and not fionna.movement_locked and room.anchor.support.collision_layer==0 and not room.crank.solved)

func run() -> void:
	root.size=Vector2i(1152,648)
	for slot in [1,2]: await route(slot)
	for start in range(1,6):
		await fresh(2,start)
		check("explicit test start %d has safe floor and label"%start,cake.is_on_floor() and fionna.is_on_floor() and has_clear_body(cake) and has_clear_body(fionna) and room.get_node("Instructions/Text").text.contains("INÍCIO DE TESTE"))
	release()
	room.queue_free()
	await frames(4)
	if not report_path.is_empty(): FileAccess.open(report_path,FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"headless":DisplayServer.get_name()=="headless","full_phase_completion":true,"fixture_positions_are_route_evidence":false},"\t"))
	print("Level2 checks: ",checks.size()," failures: ",failures)
	quit(0 if failures==0 else 1)

func ridge(actor: CoopPlayer) -> bool:
	if not await walk(actor,1120):return false
	if not await jump(actor,1184):return false
	if not await jump(actor,1280):return false
	return await walk(actor,1424)
