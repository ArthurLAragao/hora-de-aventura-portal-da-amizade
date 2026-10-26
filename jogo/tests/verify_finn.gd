extends SceneTree
## Run with --script res://tests/verify_finn.gd. Optional --capture-dir=ABS_PATH
## stores actual rendered frames in a windowed run; no mock images are used.

var failures := 0
var checks: Array[Dictionary] = []
var capture_dir := ""
var report_path := ""
var room: Node2D
var first: CoopPlayer
var second: CoopPlayer

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="):
			capture_dir = argument.trim_prefix("--capture-dir=")
		if argument.begins_with("--report="):
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
	player.global_position = point
	player.velocity = Vector2.ZERO
	player._interaction_left = 0.0
	player._landing_left = 0.0
	player._facing = 1.0
	await _frames(10)

func _capture(filename: String) -> void:
	if capture_dir.is_empty() or DisplayServer.get_name() == "headless":
		return
	DirAccess.make_dir_recursive_absolute(capture_dir)
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_png(capture_dir.path_join(filename))
	_check("render capture " + filename, result == OK)

func _test_player(player: CoopPlayer, partner: CoopPlayer, lever: CoopLever, gate: CoopGate) -> void:
	var prefix := "p%d" % player.player_id
	var tag := "Finn " + prefix + ": "
	# Setup uses explicit safe positions; no fall-zone recovery is involved.
	await _place(partner, Vector2(180, 200))
	await _place(player, Vector2(80, 329))
	await _frames(20)
	_check(tag + "identity and capabilities independent of slot", player.character_id == &"finn" and player.has_ability(&"push") and player.has_ability(&"lever"))
	_check(tag + "original speed and jump preserved", player.speed == 180.0 and player.jump_velocity == -360.0)
	_check(tag + "ground collision and idle", player.is_on_floor() and player.animated_sprite.animation == &"idle")
	var start_x := player.position.x
	var partner_x := partner.position.x
	Input.action_press(prefix + "_right")
	await _frames(10)
	_check(tag + "independent motion and walk", player.position.x > start_x + 20 and absf(partner.position.x - partner_x) < 1.0 and player.animated_sprite.animation == &"walk")
	_check(tag + "right-facing sprite", not player.animated_sprite.flip_h)
	await _capture(prefix + "-walk.png")
	Input.action_release(prefix + "_right")
	Input.action_press(prefix + "_left")
	await _frames(8)
	_check(tag + "left-facing sprite", player.animated_sprite.flip_h)
	Input.action_release(prefix + "_left")
	await _frames(12)
	Input.action_press(prefix + "_ability")
	await _frames(6)
	_check(tag + "empty ability does not fake a push", player.animated_sprite.animation != &"push")
	Input.action_release(prefix + "_ability")
	Input.action_press(prefix + "_jump")
	await _frames(2)
	Input.action_release(prefix + "_jump")
	_check(tag + "immediate jump with ascent pose", player.velocity.y < -300 and player.animated_sprite.animation == &"jump")
	await _capture(prefix + "-jump.png")
	var saw_fall := false
	var saw_land := false
	var highest_y := player.position.y
	for frame in 65:
		await _frames(1)
		highest_y = minf(highest_y, player.position.y)
		if not saw_fall and player.animated_sprite.animation == &"fall":
			await _capture(prefix + "-fall.png")
		if not saw_land and player.animated_sprite.animation == &"land":
			await _capture(prefix + "-land.png")
		saw_fall = saw_fall or player.animated_sprite.animation == &"fall"
		saw_land = saw_land or player.animated_sprite.animation == &"land"
	_check(tag + "descent and landing poses observed", saw_fall and saw_land)
	_check(tag + "jump height remains about 63-69 px", highest_y > 260 and highest_y < 268)
	_check(tag + "landing returns to idle without locking", player.is_on_floor() and player.animated_sprite.animation == &"idle" and not player.movement_locked)

	# Walk off the ledge, then press jump on the first airborne input tick.
	await _place(player, Vector2(300, 269))
	_check(tag + "ledge setup grounded", player.is_on_floor())
	Input.action_press(prefix + "_right")
	var edge_wait := 0
	while player.is_on_floor() and edge_wait < 25:
		await _frames(1)
		edge_wait += 1
	Input.action_press(prefix + "_jump")
	await _frames(1)
	Input.action_release(prefix + "_jump")
	_check(tag + "coyote jump after leaving ledge", player.velocity.y < -300)
	Input.action_release(prefix + "_right")
	await _frames(70)
	await _place(player, Vector2(300, 269))
	Input.action_press(prefix + "_right")
	edge_wait = 0
	while player.is_on_floor() and edge_wait < 25:
		await _frames(1)
		edge_wait += 1
	await _frames(9)
	Input.action_press(prefix + "_jump")
	await _frames(1)
	Input.action_release(prefix + "_jump")
	_check(tag + "expired coyote cannot become an air jump", player.velocity.y > 0)
	Input.action_release(prefix + "_right")
	await _frames(60)

	await _place(player, Vector2(380, 329))
	player.position.y -= 100
	player.velocity.y = 80.0
	while player.position.y < 310.0:
		await _frames(1)
	Input.action_press(prefix + "_jump")
	await _frames(1)
	Input.action_release(prefix + "_jump")
	_check(tag + "buffer request occurs in descent after coyote expired", player.velocity.y > 0 and not player.is_on_floor())
	var buffered_jump := false
	for frame in 12:
		await _frames(1)
		buffered_jump = buffered_jump or player.velocity.y < -300
	_check(tag + "buffer executes jump upon landing", buffered_jump)
	await _frames(60)
	await _place(player, Vector2(380, 329))
	player.position.y -= 100
	player.velocity.y = 0.0
	await _frames(9)
	Input.action_press(prefix + "_jump")
	await _frames(1)
	Input.action_release(prefix + "_jump")
	buffered_jump = false
	for frame in 50:
		await _frames(1)
		buffered_jump = buffered_jump or player.velocity.y < -300
	_check(tag + "expired buffer does not jump on later landing", not buffered_jump and player.is_on_floor())

	await _place(partner, Vector2(500, 329))
	await _place(player, Vector2(18, 329))
	Input.action_press(prefix + "_left")
	await _frames(15)
	Input.action_release(prefix + "_left")
	_check(tag + "left wall blocks without sinking", player.position.x >= 10 and player.is_on_floor())

	var log := room.get_node("Log") as PushBlock
	log.reset_to_start()
	await _place(player, Vector2(380, 329))
	Input.action_press(prefix + "_ability")
	await _frames(8)
	Input.action_release(prefix + "_ability")
	_check(tag + "cannot push a distant log", absf(log.position.x - 450.0) < 0.1 and player.animated_sprite.animation != &"push")
	await _place(player, Vector2(410, 329))
	Input.action_press(prefix + "_right")
	Input.action_press(prefix + "_ability")
	var saw_push := false
	for frame in 16:
		await _frames(1)
		saw_push = saw_push or player.animated_sprite.animation == &"push"
	_check(tag + "actual log motion triggers push animation", log.position.x > 475 and saw_push)
	await _capture(prefix + "-push.png")
	Input.action_release(prefix + "_right")
	Input.action_release(prefix + "_ability")
	await _frames(15)
	_check(tag + "push ends when object stops", player.animated_sprite.animation != &"push")
	Input.action_press(prefix + "_reset")
	await _frames(2)
	Input.action_release(prefix + "_reset")
	_check(tag + "own reset action restores log", absf(log.position.x - 450.0) < 0.1)

	# A request with the log against a solid wall must not show a successful push.
	log.position.x = 935.9
	await _place(player, Vector2(900, 329))
	Input.action_press(prefix + "_ability")
	await _frames(12)
	_check(tag + "wall-blocked log has no false push pose", player.animated_sprite.animation != &"push" and log.position.x < 936.1)
	Input.action_release(prefix + "_ability")
	log.reset_to_start()

	await _place(partner, Vector2(250, 200))
	await _place(player, lever.position)
	await _frames(4)
	_check(tag + "lever prompt matches player input", lever.prompt_label.visible and lever.prompt_label.text == ("E" if player.player_id == 1 else "Enter"))
	var wrong_action := "p2_interact" if player.player_id == 1 else "p1_interact"
	Input.action_press(wrong_action)
	await _frames(2)
	Input.action_release(wrong_action)
	_check(tag + "other slot cannot activate this Finn", not gate.is_open)
	Input.action_press(prefix + "_interact")
	await _frames(2)
	Input.action_release(prefix + "_interact")
	_check(tag + "valid lever opens gate and starts correct clip", gate.is_open and player.animated_sprite.animation == &"pull_lever")
	var interaction_x := player.position.x
	Input.action_press(prefix + "_left")
	await _frames(8)
	_check(tag + "interaction survives movement without locking controls", player.animated_sprite.animation == &"pull_lever" and player.position.x < interaction_x - 15 and not player.movement_locked)
	await _capture(prefix + "-lever.png")
	Input.action_release(prefix + "_left")
	await _frames(65)
	_check(tag + "interaction naturally returns to locomotion", player.animated_sprite.animation == &"idle" and not player.movement_locked)
	await _place(player, lever.position)
	Input.action_press(prefix + "_interact")
	await _frames(2)
	Input.action_release(prefix + "_interact")
	_check(tag + "solved lever cannot replay a fake action", player.animated_sprite.animation != &"pull_lever")

func _test_level() -> void:
	_release_inputs()
	room.queue_free()
	await _frames(4)
	var level := (load("res://level_1.tscn") as PackedScene).instantiate()
	root.add_child(level)
	current_scene = level
	await _frames(20)
	var finn := level.get_node("Players/Finn") as CoopPlayer
	var jake := level.get_node("Players/Jake") as CoopPlayer
	_check("level: both characters grounded", finn.is_on_floor() and jake.is_on_floor())
	_check("level: Jake preserves speed/jump and lacks Finn capabilities", jake.speed == 180.0 and jake.jump_velocity == -360.0 and not jake.has_ability(&"push") and not jake.has_ability(&"lever"))
	Input.action_press("p2_right")
	await _frames(10)
	Input.action_release("p2_right")
	_check("level: Jake moves with existing walk clip", jake.position.x > 320 and jake.animated_sprite.animation == &"walk")
	Input.action_press("p2_jump")
	await _frames(2)
	Input.action_release("p2_jump")
	_check("level: Jake still jumps", jake.velocity.y < -300)
	await _frames(60)
	var bypassed_bridge := false
	for delay in range(6):
		await _place(finn, Vector2(430, 245))
		Input.action_press("p1_right")
		var edge_wait := 0
		while finn.is_on_floor() and edge_wait < 20:
			await _frames(1)
			edge_wait += 1
		await _frames(delay)
		var launch_point := finn.position
		Input.action_press("p1_jump")
		await _frames(1)
		Input.action_release("p1_jump")
		for frame in 58:
			await _frames(1)
			bypassed_bridge = bypassed_bridge or (finn.position.x > 618 and finn.is_on_floor())
			if finn.position.y > 400:
				break
		Input.action_release("p1_right")
		print("GAP trial delay=", delay, " launch=", launch_point, " end=", finn.position, " bypass=", bypassed_bridge)
	_check("level: coyote timing cannot bypass Jake's bridge", not bypassed_bridge)

	# Reach the anchor by walking. Crossing uses an actual held bridge, never
	# the known faulty fall-zone checkpoint shortcut.
	finn.global_position = Vector2(380, 245)
	jake.global_position = Vector2(444, 245)
	finn.velocity = Vector2.ZERO
	jake.velocity = Vector2.ZERO
	await _frames(8)
	Input.action_press("p2_ability")
	await _frames(100)
	var bridge := level.get_node("JakeBridge") as JakeBridge
	_check("level: Jake bridge locks him and supports crossing", jake.movement_locked and bridge.bridge_body.collision_layer == 1)
	Input.action_press("p1_right")
	Input.action_press("p1_jump")
	await _frames(1)
	Input.action_release("p1_jump")
	var crossed := true
	for frame in 95:
		await _frames(1)
		if finn.position.y > 350:
			crossed = false
	Input.action_release("p1_right")
	_check("level: Finn crosses active bridge with a jump and no fall", crossed and finn.position.x > 640 and finn.is_on_floor())
	Input.action_press("p1_interact")
	await _frames(2)
	Input.action_release("p1_interact")
	_check("level: Finn lever opens permanent passage", level.get_node("PermanentBridge").collision_layer == 1)
	await _capture("level1-finn-jake-bridge.png")
	Input.action_release("p2_ability")
	await _frames(100)
	_check("level: Jake retracts and regains control", not jake.movement_locked and bridge.bridge_body.collision_layer == 0)
	Input.action_press("p2_right")
	Input.action_press("p2_jump")
	await _frames(1)
	Input.action_release("p2_jump")
	var jake_crossed_without_fall := true
	for frame in 90:
		await _frames(1)
		if jake.position.y > 350:
			jake_crossed_without_fall = false
	Input.action_release("p2_right")
	_check("level: Jake crosses permanent passage physically", jake_crossed_without_fall and jake.position.x > 640 and jake.position.y < 300 and jake.is_on_floor())
	var lever := level.get_node("Lever") as CoopLever
	lever._is_activated = false
	var actor_without_ability := jake
	actor_without_ability.global_position = lever.position
	await _frames(4)
	_check("level: Jake rejected by capability even in range", not lever.activate(actor_without_ability))
	await _capture("level1-finn-jake.png")
	print("KNOWN PENDING: checkpoint activation guard unchanged; recovery is not progression evidence.")
	_release_inputs()
	level.queue_free()
	await _frames(4)

func _run() -> void:
	root.size = Vector2i(1152, 648)
	room = (load("res://tests/finn_test.tscn") as PackedScene).instantiate() as Node2D
	root.add_child(room)
	current_scene = room
	await _frames(30)
	first = room.get_node("FinnP1") as CoopPlayer
	second = room.get_node("FinnP2") as CoopPlayer
	var resource := first.animated_sprite.sprite_frames
	_check("Finn uses existing resource without copied frames", resource.resource_path == "res://Assets/01_Characters/finn/animations.tres" and resource.get_frame_count(&"jump") == 2)
	var has_space := false
	var has_w := false
	for event in InputMap.action_get_events("p1_jump"):
		if event is InputEventKey:
			has_space = has_space or event.physical_keycode == KEY_SPACE
			has_w = has_w or event.physical_keycode == KEY_W
	_check("Input Map retains Space and adds physical W", has_space and has_w)
	for key in [KEY_W, KEY_SPACE]:
		await _place(first, Vector2(80, 329))
		var pressed := InputEventKey.new()
		pressed.physical_keycode = key
		pressed.pressed = true
		Input.parse_input_event(pressed)
		await _frames(2)
		_check("physical key event jumps Finn P1: " + OS.get_keycode_string(key), first.velocity.y < -300 and second.velocity.y >= 0)
		var released := InputEventKey.new()
		released.physical_keycode = key
		Input.parse_input_event(released)
		await _frames(60)
	await _capture("finn-test-room.png")
	await _test_player(first, second, room.get_node("LeverA"), room.get_node("GateA"))
	await _test_player(second, first, room.get_node("LeverB"), room.get_node("GateB"))
	await _test_level()
	if not report_path.is_empty():
		var report := FileAccess.open(report_path, FileAccess.WRITE)
		if report != null:
			report.store_string(JSON.stringify({"checks": checks, "failures": failures, "checkpoint_validated": false}, "\t"))
	print("Finn checks: ", checks.size(), " | failures: ", failures)
	await create_timer(1.0).timeout
	quit(0 if failures == 0 else 1)
