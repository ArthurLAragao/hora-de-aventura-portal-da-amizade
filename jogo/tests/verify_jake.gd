extends SceneTree

var demo_only := false
var failures := 0
var checks: Array[Dictionary] = []
var capture_dir := ""
var report_path := ""
var room: Node2D
var jake: CoopPlayer
var finn: CoopPlayer
var bridge: JakeBridge

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument == "--demo":
			demo_only = true
		if argument.begins_with("--capture-dir="):
			capture_dir = argument.trim_prefix("--capture-dir=")
		elif argument.begins_with("--report="):
			report_path = argument.trim_prefix("--report=")
	call_deferred("_run")

func _check(label: String, condition: bool) -> void:
	checks.append({"check": label, "passed": condition})
	print(("PASS " if condition else "FAIL ") + label)
	if not condition:
		failures += 1

func _frames(count: int) -> void:
	for frame in count:
		await physics_frame
		await process_frame

func _release_inputs() -> void:
	for action in InputMap.get_actions():
		if String(action).begins_with("p1_") or String(action).begins_with("p2_"):
			Input.action_release(action)

func _place(player: CoopPlayer, point: Vector2) -> void:
	_release_inputs()
	player.position = point
	player.velocity = Vector2.ZERO
	await _frames(12)

func _capture(filename: String) -> void:
	if capture_dir.is_empty() or DisplayServer.get_name() == "headless":
		return
	DirAccess.make_dir_recursive_absolute(capture_dir)
	await RenderingServer.frame_post_draw
	_check("real render " + filename, root.get_texture().get_image().save_png(capture_dir.path_join(filename)) == OK)

func _load_room(role: int) -> void:
	_release_inputs()
	if is_instance_valid(room):
		room.queue_free()
		await _frames(4)
	room = (load("res://tests/jake_test.tscn") as PackedScene).instantiate() as Node2D
	room.set("jake_player_id", role)
	root.add_child(room)
	current_scene = room
	jake = room.get_node("Jake") as CoopPlayer
	finn = room.get_node("Finn") as CoopPlayer
	bridge = room.get_node("JakeBridge") as JakeBridge
	await _frames(25)

func _test_role(role: int) -> void:
	await _load_room(role)
	var prefix := "p%d" % role
	var other := "p%d" % (3 - role)
	var tag := "Jake " + prefix + ": "
	_check(tag + "identity and bridge capability, no Finn powers", jake.character_id == &"jake" and jake.has_ability(&"bridge") and not jake.has_ability(&"push") and not jake.has_ability(&"lever"))
	_check(tag + "controls/meta follow player slot", jake.player_id == role and int(jake.get_meta("player_id")) == role and finn.player_id == 3 - role)
	_check(tag + "original speed, jump and collider preserved", jake.speed == 180 and jake.jump_velocity == -360 and (jake.get_node("CollisionShape2D").shape as RectangleShape2D).size == Vector2(29, 37))
	_check(tag + "jump tolerances configured", is_equal_approx(jake.coyote_time, 0.03) and is_equal_approx(jake.jump_buffer_time, 0.12))
	var frames := jake.animated_sprite.sprite_frames
	_check(tag + "existing animations and frame counts", frames.resource_path == "res://Assets/01_Characters/jake/animations.tres" and frames.get_frame_count(&"walk") == 8 and frames.get_frame_count(&"bridge_extend") == 4 and frames.get_frame_count(&"bridge_hold") == 1)
	_check(tag + "grounded and idle, feet match Finn", jake.is_on_floor() and jake.animated_sprite.animation == &"idle" and absf(jake.position.y - finn.position.y) < 0.1)
	await _capture(prefix + "-idle.png")
	await _place(jake, Vector2(220, 245))
	var partner_x := finn.position.x
	Input.action_press(prefix + "_right")
	await _frames(10)
	_check(tag + "walk moves only Jake, facing right", jake.position.x > 245 and absf(finn.position.x - partner_x) < 0.1 and jake.animated_sprite.animation == &"walk" and not jake.animated_sprite.flip_h)
	await _capture(prefix + "-walk.png")
	Input.action_release(prefix + "_right")
	Input.action_press(prefix + "_left")
	await _frames(10)
	Input.action_release(prefix + "_left")
	_check(tag + "facing left", jake.animated_sprite.flip_h)
	await _frames(12)
	Input.action_press(prefix + "_jump")
	await _frames(2)
	Input.action_release(prefix + "_jump")
	_check(tag + "ascent clip and immediate jump", jake.velocity.y < -300 and jake.animated_sprite.animation == &"jump")
	await _capture(prefix + "-jump.png")
	var saw_fall := false
	var saw_land := false
	var min_y := jake.position.y
	for frame in 65:
		await _frames(1)
		min_y = minf(min_y, jake.position.y)
		if not saw_fall and jake.animated_sprite.animation == &"fall":
			await _capture(prefix + "-fall.png")
		if not saw_land and jake.animated_sprite.animation == &"land":
			await _capture(prefix + "-land.png")
		saw_fall = saw_fall or jake.animated_sprite.animation == &"fall"
		saw_land = saw_land or jake.animated_sprite.animation == &"land"
	_check(tag + "fall/land clips observed, original jump height", saw_fall and saw_land and min_y > 180 and min_y < 188)
	_check(tag + "land returns to idle without lock", jake.is_on_floor() and not jake.movement_locked and jake.animated_sprite.animation == &"idle")
	await _place(jake, Vector2(145, 189))
	_check(tag + "ledge test starts grounded", jake.is_on_floor())
	Input.action_press(prefix + "_right")
	var edge_ticks := 0
	while jake.is_on_floor() and edge_ticks < 20:
		await _frames(1)
		edge_ticks += 1
	Input.action_press(prefix + "_jump")
	await _frames(1)
	Input.action_release(prefix + "_jump")
	Input.action_release(prefix + "_right")
	_check(tag + "short coyote jump after ledge", jake.velocity.y < -300)
	await _frames(65)
	await _place(jake, Vector2(220, 245))
	jake.position.y -= 100
	jake.velocity.y = 80
	while jake.position.y < 230:
		await _frames(1)
	Input.action_press(prefix + "_jump")
	await _frames(1)
	Input.action_release(prefix + "_jump")
	_check(tag + "buffer pressed in descent, no air jump", not jake.is_on_floor() and jake.velocity.y > 0)
	var buffered := false
	for frame in 12:
		await _frames(1)
		buffered = buffered or jake.velocity.y < -300
	_check(tag + "buffered jump upon landing", buffered)
	await _frames(65)
	await _place(jake, Vector2(20, 245))
	Input.action_press(prefix + "_left")
	await _frames(15)
	Input.action_release(prefix + "_left")
	_check(tag + "wall collision and stable ground", jake.position.x >= 13.5 and jake.is_on_floor())

	await _test_compact(role)

func _until(predicate: Callable, limit: int = 180) -> bool:
	for i in limit:
		if predicate.call():
			return true
		await _frames(1)
	return predicate.call()

func _position(player: CoopPlayer, point: Vector2, wait: int = 12) -> void:
	# Fixture placement only, never used as evidence of crossing.
	player.position = point
	player.velocity = Vector2.ZERO
	await _frames(wait)

func _ready_compact(role: int, x: float = 448) -> bool:
	await _load_room(role)
	await _position(jake, Vector2(x, 245))
	Input.action_press("p%d_ability" % role)
	return await _until(func(): return bridge.state == JakeBridge.State.HOLDING)

func _finish_release(role: int) -> bool:
	Input.action_release("p%d_ability" % role)
	return await _until(func(): return bridge.state == JakeBridge.State.IDLE)

func _single_representation() -> bool:
	return jake.animated_sprite.visible != bridge.bridge_visual.visible

func _mask(name: String) -> void:
	if capture_dir.is_empty() or DisplayServer.get_name() == "headless" or demo_only:
		return
	var view := SubViewport.new()
	view.size = Vector2i(320, 128)
	view.transparent_bg = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(view)
	var copy := JakeBridgeVisual.new()
	copy.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	copy.position = Vector2(80, 50)
	view.add_child(copy)
	var original := bridge.bridge_visual
	copy.configure(original.source_frame, original.source_origin, original.pixel_scale, original.source_origin.x + 48 * original.pixel_scale + original.extra_length, bridge.get_support_rect().position.y)
	copy.set_progress(1)
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	_check("rendered support mask " + name, view.get_texture().get_image().save_png(capture_dir.path_join(name + ".png")) == OK)
	view.queue_free()
	await _frames(1)

func _test_compact(role: int) -> void:
	await _load_room(role)
	var jp := "p%d" % role
	var fp := "p%d" % (3-role)
	var tag := "Compact Jake P%d: " % role
	_check(tag+"local support geometry 178x18 at (71,24)", bridge.bridge_body.position == Vector2(71,24) and bridge.get_support_rect() == Rect2(-18,15,178,18))
	_check(tag+"post and marker separate from anchor origin", bridge.anchor_visual.position == Vector2(-38,0) and bridge.get_node("ActivationMarker").position.x == -18)
	_check(tag+"initial bridge disabled and no duplicate", bridge.bridge_body.collision_layer == 0 and _single_representation())
	for x in [395.0, 420.0, 438.0, 449.0]:
		await _position(jake,Vector2(x,245))
		Input.action_press(jp+"_ability")
		await _frames(4)
		_check(tag+"reject invalid origin x="+str(x), bridge.state == JakeBridge.State.IDLE and not jake.movement_locked)
		Input.action_release(jp+"_ability")
	await _position(jake,Vector2(444,245))
	Input.action_press(jp+"_jump")
	await _frames(2)
	Input.action_release(jp+"_jump")
	Input.action_press(jp+"_ability")
	await _frames(2)
	_check(tag+"reject activation in air", bridge.state == JakeBridge.State.IDLE and not jake.movement_locked)
	Input.action_release(jp+"_ability")
	await _frames(65)
	await _position(finn,Vector2(444,245))
	await _position(jake,Vector2(395,245))
	Input.action_press(fp+"_ability")
	await _frames(5)
	_check(tag+"Finn cannot activate anchor", bridge.state == JakeBridge.State.IDLE)
	Input.action_release(fp+"_ability")
	await _position(finn,Vector2(320,245))
	await _position(jake,Vector2(444,245))
	Input.action_press(fp+"_ability")
	await _frames(4)
	_check(tag+"partner input does not activate Jake", bridge.state == JakeBridge.State.IDLE)
	Input.action_release(fp+"_ability")

	for x in [440.0,441.5,444.0,447.5,448.0]:
		await _position(jake,Vector2(x,245))
		var original_position := jake.position
		var original_frames := jake.animated_sprite.sprite_frames
		Input.action_press(jp+"_ability")
		await _frames(2)
		_check(tag+"source extension keeps support OFF x="+str(x), bridge.state == JakeBridge.State.EXTENDING and bridge.bridge_body.collision_layer == 0 and _single_representation())
		if x == 448:
			await _capture(jp+"-source-extension.png")
		var no_early_support := true
		var unique := true
		var waited := 0
		while bridge.state != JakeBridge.State.HOLDING and waited < 180:
			if bridge.bridge_body.collision_layer == 1 and (bridge.bridge_visual.progress < 1.0 or not bridge.bridge_visual.has_full_render()):
				no_early_support = false
			unique = unique and _single_representation()
			if x == 448 and waited == 45:
				await _capture(jp+"-growth.png")
			await _frames(1)
			waited += 1
		var back := bridge.bridge_visual.get_flat_back_rect()
		var support := bridge.get_support_rect()
		_check(tag+"valid origin "+str(x)+" full bridge without reposition", bridge.state == JakeBridge.State.HOLDING and jake.position.distance_to(original_position)<0.001)
		_check(tag+"no invisible support and one Jake "+str(x), no_early_support and unique and bridge.bridge_visual.has_full_render())
		_check(tag+"visible back covers support "+str(x), back.position.x <= support.position.x+0.001 and absf(back.position.y-support.position.y)<0.001 and absf(back.end.x-support.end.x)<0.001)
		_check(tag+"shared animation resource untouched "+str(x), jake.animated_sprite.sprite_frames == original_frames and jake.animated_sprite.scale == Vector2.ONE)
		await _mask(jp+"-mask-"+str(x).replace(".","_"))
		if x == 448:
			await _capture(jp+"-hold.png")
		var released := await _finish_release(role)
		_check(tag+"release restores sprite/control and clears collision "+str(x), released and not jake.movement_locked and jake.animated_sprite.visible and not bridge.bridge_visual.visible and bridge.bridge_body.collision_layer == 0)
	
	for partial in [false,true]:
		await _position(jake,Vector2(444,245))
		Input.action_press(jp+"_ability")
		if partial:
			await _until(func():return bridge.step == JakeBridge.Step.GROW and bridge.bridge_visual.progress > 0.2)
		else:
			await _frames(2)
		var never_enabled := bridge.bridge_body.collision_layer == 0
		Input.action_release(jp+"_ability")
		for frame in 140:
			never_enabled = never_enabled and bridge.bridge_body.collision_layer == 0
			if bridge.state == JakeBridge.State.IDLE:
				break
			await _frames(1)
		_check(tag+"early cancel partial="+str(partial), never_enabled and bridge.state == JakeBridge.State.IDLE and not jake.movement_locked and _single_representation())
	_check(tag+"reactivation after cancel", await _ready_compact(role,444))
	await _position(finn,Vector2(528,239))
	_check(tag+"Finn really grounded on bridge", finn.is_on_floor() and absf(finn.position.y-239)<0.1 and bridge.get_dependents().has(finn))
	Input.action_release(jp+"_ability")
	await _frames(65)
	_check(tag+"release while occupied waits without timeout collapse", bridge.state == JakeBridge.State.HOLDING and bridge.release_pending and bridge.bridge_body.collision_layer == 1 and jake.movement_locked)
	var no_fall := true
	Input.action_press(fp+"_right")
	for frame in 52:
		await _frames(1)
		no_fall = no_fall and finn.position.y<300
	Input.action_release(fp+"_right")
	await _until(func():return bridge.state==JakeBridge.State.IDLE)
	_check(tag+"Finn exits by walking then Jake recovers", no_fall and finn.position.x>640 and finn.is_on_floor() and not jake.movement_locked and bridge.bridge_body.collision_layer==0)
	await _capture(jp+"-after-occupied-release.png")
	
	_check(tag+"activate for airborne release", await _ready_compact(role,448))
	await _position(finn,Vector2(528,239))
	Input.action_press(fp+"_jump")
	await _frames(3)
	Input.action_release(fp+"_jump")
	Input.action_release(jp+"_ability")
	var safely_held := true
	for frame in 50:
		await _frames(1)
		safely_held = safely_held and bridge.bridge_body.collision_layer==1
	_check(tag+"in-place airborne partner protected through landing", safely_held and bridge.state==JakeBridge.State.HOLDING and finn.is_on_floor())
	Input.action_press(fp+"_right")
	await _until(func():return finn.position.x>645)
	Input.action_release(fp+"_right")
	await _until(func():return bridge.state==JakeBridge.State.IDLE)

	_check(tag+"activate for moving jump release", await _ready_compact(role,444))
	await _position(finn,Vector2(528,239))
	Input.action_press(fp+"_jump")
	Input.action_press(fp+"_right")
	await _frames(3)
	Input.action_release(fp+"_jump")
	Input.action_release(jp+"_ability")
	var air_protected := not finn.is_on_floor()
	no_fall = true
	for frame in 65:
		await _frames(1)
		no_fall = no_fall and finn.position.y<300
		if finn.position.x+10.5>430 and finn.position.x-10.5<608 and finn.position.y<239:
			air_protected = air_protected and bridge.bridge_body.collision_layer==1
	Input.action_release(fp+"_right")
	await _until(func():return bridge.state==JakeBridge.State.IDLE)
	_check(tag+"moving airborne partner protected over gap", air_protected and no_fall and finn.position.x>640 and finn.is_on_floor())
	
	await _load_room(role)
	room.position=Vector2(83,47)
	room.scale=Vector2(1.25,1.25)
	await _frames(12)
	await _position(jake,Vector2(444,245))
	Input.action_press(jp+"_ability")
	var transformed := await _until(func():return bridge.state==JakeBridge.State.HOLDING)
	var local_back:=bridge.bridge_visual.get_flat_back_rect()
	_check(tag+"translated/scaled room uses anchor-local geometry", transformed and absf(local_back.end.x-160)<0.01 and absf(local_back.position.y-15)<0.01)
	await _finish_release(role)
	
	if DisplayServer.get_name() != "headless":
		await _load_room(role)
		await _position(jake,Vector2(444,245))
		Input.action_press(jp+"_ability")
		await _until(func():return bridge.step==JakeBridge.Step.GROW)
		bridge.bridge_visual.hide()
		var unsafe := false
		for frame in 360:
			await _frames(1)
			unsafe = unsafe or bridge.bridge_body.collision_layer==1
			# Stop requesting a new activation once the render timeout has
			# cancelled this attempt; at low FPS an idle tick can be skipped.
			if bridge.step==JakeBridge.Step.SHRINK:
				Input.action_release(jp+"_ability")
			if bridge.state==JakeBridge.State.IDLE:
				break
		Input.action_release(jp+"_ability")
		if unsafe or bridge.state!=JakeBridge.State.IDLE or jake.movement_locked:
			print("Render guard diagnostic: unsafe=",unsafe," state=",bridge.state," step=",bridge.step," locked=",jake.movement_locked)
		_check(tag+"no rendered full bridge cancels without invisible floor", not unsafe and bridge.state==JakeBridge.State.IDLE and not jake.movement_locked)
	
	await _load_room(role)
	await _position(jake,Vector2(660,245))
	_check(tag+"Jake still cannot use Finn's lever", not (room.get_node("Lever") as CoopLever).activate(jake))
	await _position(jake,Vector2(444,245))
	Input.action_press(jp+"_ability")
	await _frames(3)
	bridge.queue_free()
	await _frames(4)
	Input.action_release(jp+"_ability")
	_check(tag+"scene removal during source phase restores sprite/control", not jake.movement_locked and jake.animated_sprite.visible and jake.animation_override==&"")

func _walk_to(player: CoopPlayer, action: String, threshold: float, limit: int=240) -> bool:
	Input.action_press(action)
	var reached := await _until(func():return player.position.x>=threshold,limit)
	Input.action_release(action)
	await _frames(12)
	return reached

func _test_level(role: int) -> void:
	_release_inputs()
	if is_instance_valid(room):
		room.queue_free()
		await _frames(4)
	room=(load("res://level_1.tscn") as PackedScene).instantiate()
	jake=room.get_node("Players/Jake")
	finn=room.get_node("Players/Finn")
	jake.player_id=role
	finn.player_id=3-role
	root.add_child(room)
	current_scene=room
	await _frames(25)
	bridge=room.get_node("JakeBridge")
	var jp:="p%d"%role
	var fp:="p%d"%(3-role)
	var tag:="Real level Jake P%d: "%role
	var start:=jake.position
	Input.action_press(jp+"_ability")
	Input.action_press(jp+"_right")
	var approached:=await _until(func():return bridge.state!=JakeBridge.State.IDLE)
	Input.action_release(jp+"_right")
	_check(tag+"walks from spawn into tolerant band, no teleport", approached and jake.position.x>=440 and jake.position.x<=448 and jake.position.x>start.x+100)
	await _until(func():return bridge.step==JakeBridge.Step.GROW and bridge.bridge_visual.progress>0.3)
	await _capture("level-"+jp+"-growth.png")
	await _until(func():return bridge.state==JakeBridge.State.HOLDING)
	_check(tag+"full drawing precedes collision", bridge.bridge_body.collision_layer==1 and bridge.bridge_visual.has_full_render() and _single_representation())
	# Entire route below uses real input, with no fixture placement or fall recovery.
	Input.action_press(fp+"_right")
	await _until(func():return finn.position.x>=380)
	Input.action_press(fp+"_jump")
	await _frames(1)
	Input.action_release(fp+"_jump")
	await _until(func():return finn.position.x>=440)
	Input.action_release(fp+"_right")
	var no_fall:=true
	for frame in 55:
		await _frames(1)
		no_fall=no_fall and finn.position.y<350
		if finn.is_on_floor() and finn.position.x>430:
			break
	_check(tag+"Finn enters by jumping and lands on visible back", no_fall and finn.is_on_floor() and finn.position.x>430 and finn.position.x<470 and absf(finn.position.y-239)<0.2)
	await _capture("level-"+jp+"-entry.png")
	no_fall=no_fall and await _walk_to(finn,fp+"_right",517)
	_check(tag+"Finn reaches center without recovery", no_fall and finn.position.x>520 and finn.position.x<540 and finn.is_on_floor())
	await _capture("level-"+jp+"-center.png")
	no_fall=no_fall and await _walk_to(finn,fp+"_right",585)
	_check(tag+"Finn reaches exit without recovery", no_fall and finn.position.x>588 and finn.position.x<610 and finn.is_on_floor())
	await _capture("level-"+jp+"-exit.png")
	await _walk_to(finn,fp+"_right",652)
	await process_frame
	Input.action_press(fp+"_interact")
	await _frames(3)
	Input.action_release(fp+"_interact")
	_check(tag+"Finn lever opens permanent passage", room.get_node("PermanentBridge").collision_layer==1)
	Input.action_release(jp+"_ability")
	await _until(func():return bridge.state==JakeBridge.State.IDLE)
	_check(tag+"Jake normal sprite/control restored, no ghost collision", not jake.movement_locked and jake.animated_sprite.visible and bridge.bridge_body.collision_layer==0 and not bridge.bridge_visual.visible)
	Input.action_press(jp+"_right")
	Input.action_press(jp+"_jump")
	await _frames(1)
	Input.action_release(jp+"_jump")
	for frame in 90:
		await _frames(1)
		no_fall=no_fall and jake.position.y<350
		if jake.position.x>650 and jake.is_on_floor():
			break
	Input.action_release(jp+"_right")
	await _frames(12)
	_check(tag+"Jake follows permanent path physically", no_fall and jake.position.x>650 and jake.is_on_floor())
	await _capture("level-"+jp+"-permanent.png")
	print("CHECKPOINT PENDING: not validated; no fall recovery accepted as crossing.")

func _run() -> void:
	root.size=Vector2i(1152,648)
	if demo_only:
		await _test_level(2)
	else:
		await _test_role(1)
		await _test_role(2)
		await _test_level(1)
		await _test_level(2)
	_release_inputs()
	if is_instance_valid(room):
		room.queue_free()
	await _frames(4)
	if not report_path.is_empty():
		FileAccess.open(report_path,FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"checkpoint_validated":false,"headless":DisplayServer.get_name()=="headless"},"\t"))
	print("Jake checks: ",checks.size()," | failures: ",failures)
	await create_timer(0.5).timeout
	quit(0 if failures==0 else 1)

