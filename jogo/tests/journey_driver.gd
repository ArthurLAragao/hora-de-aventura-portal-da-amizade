extends SceneTree
var failures:=0
var checks: Array[Dictionary]=[]
var report_path:=""
var capture_dir:=""
var record_dir:=""
var recorded_ticks:=0
var viewport_size:=Vector2i(1152,648)
var record_interval:=30
var role:=1
var level: Node2D

func _initialize() -> void:
	if DisplayServer.get_name()!="headless": DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--report="): report_path=arg.trim_prefix("--report=")
		if arg.begins_with("--capture-dir="): capture_dir=arg.trim_prefix("--capture-dir=")
		if arg.begins_with("--record-dir="): record_dir=arg.trim_prefix("--record-dir=")
		if arg=="--resolution=1280x720": viewport_size=Vector2i(1280,720)
		if arg.begins_with("--record-interval="): record_interval=maxi(1,arg.trim_prefix("--record-interval=").to_int())
	if record_dir!="": DirAccess.make_dir_recursive_absolute(record_dir)
	call_deferred("run")

func frames(n: int) -> void:
	for i in n:
		await physics_frame
		await process_frame
		recorded_ticks+=1
		if record_dir!="" and recorded_ticks%record_interval==0:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(record_dir.path_join("%06d.png"%recorded_ticks))

func check(text: String,ok: bool) -> void:
	checks.append({"check":"P%d: %s"%[role,text],"passed":ok})
	print(("PASS " if ok else "FAIL ")+"P%d: "%role+text)
	if not ok: failures+=1

func release() -> void:
	for a in InputMap.get_actions():
		if String(a).begins_with("p1_") or String(a).begins_with("p2_"): Input.action_release(a)

func until(predicate: Callable,limit: int=240) -> bool:
	for i in limit:
		if predicate.call(): return true
		await frames(1)
	return predicate.call()

func action(actor: CoopPlayer,key: String) -> String:
	return "p%d_%s"%[actor.player_id,key]

func tap(actor: CoopPlayer,key: String,n: int=2) -> void:
	await process_frame
	Input.action_press(action(actor,key))
	await frames(n)
	Input.action_release(action(actor,key))
	await frames(3)

func steer(actor: CoopPlayer,goal: float) -> void:
	var gap:=goal-actor.position.x
	var velocity:=actor.velocity.x
	var braking:=maxf(0,absf(velocity)*(absf(velocity)-24)/(2*1440.0))
	var direction:=signf(gap) if absf(gap)>2 else 0.0
	if signf(velocity)==direction and absf(gap)<braking+2: direction=0
	for side in ["left","right"]:
		var wanted:=direction<0 if side=="left" else direction>0
		if wanted: Input.action_press(action(actor,side),minf(1.0,absf(gap)/18.0))
		else: Input.action_release(action(actor,side))

func walk(actor: CoopPlayer,goal: float,limit: int=480) -> bool:
	for i in limit:
		if level.get("_transitioning") and not actor.is_in_group("players"):
			Input.action_release(action(actor,"left"))
			Input.action_release(action(actor,"right"))
			return true
		if level.get("completion_count")!=null and level.get("completion_count")>0:
			Input.action_release(action(actor,"left"))
			Input.action_release(action(actor,"right"))
			return true
		if absf(actor.position.x-goal)<3 and absf(actor.velocity.x)<60:
			Input.action_release(action(actor,"left"))
			Input.action_release(action(actor,"right"))
			await frames(4)
			return true
		steer(actor,goal)
		await frames(1)
	Input.action_release(action(actor,"left"))
	Input.action_release(action(actor,"right"))
	print("WALK_TIMEOUT ",actor.name," at ",actor.position," target ",goal)
	return false

func jump(actor: CoopPlayer,goal: float,ability: bool=false) -> bool:
	Input.action_press(action(actor,"jump"))
	if ability: Input.action_press(action(actor,"ability"))
	await frames(2)
	Input.action_release(action(actor,"jump"))
	var reached:=await walk(actor,goal,120)
	await until(func():return actor.is_on_floor(),120)
	if ability: Input.action_release(action(actor,"ability"))
	await frames(4)
	return reached and actor.is_on_floor()

func push_until(actor: CoopPlayer,predicate: Callable,limit: int=360) -> bool:
	Input.action_press(action(actor,"right"))
	Input.action_press(action(actor,"ability"))
	var ok:=await until(predicate,limit)
	Input.action_release(action(actor,"right"))
	Input.action_release(action(actor,"ability"))
	await frames(12)
	return ok

func capture(name: String) -> void:
	if capture_dir.is_empty() or DisplayServer.get_name()=="headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(capture_dir.path_join("p%d-%s.png"%[role,name]))

func stop_test_audio(node: Node) -> void:
	for child in node.get_children(): stop_test_audio(child)
	if node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D: node.stop()

func fresh(path: String,slot: int,property: String) -> void:
	release()
	if is_instance_valid(level):
		stop_test_audio(level)
		level.queue_free()
		await frames(4)
		OS.delay_msec(80)
	role=slot
	var packed=load(path)
	if packed==null:
		check("scene loads",false)
		quit(1)
		return
	level=packed.instantiate()
	level.set(property,slot)
	root.add_child(level)
	current_scene=level
	await frames(20)

func finish(tag: String) -> void:
	release()
	if is_instance_valid(level):
		stop_test_audio(level)
		level.queue_free()
	await frames(4)
	OS.delay_msec(160)
	await frames(2)
	if report_path!="": FileAccess.open(report_path,FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"headless":DisplayServer.get_name()=="headless","viewport":str(root.size)},"\t"))
	print(tag," checks: ",checks.size()," failures: ",failures)
	quit(0 if failures==0 else 1)

func run() -> void:
	pass
