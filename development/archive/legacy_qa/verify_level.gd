extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(label: String, condition: bool) -> void:
	print(("PASS " if condition else "FAIL ") + label)
	if not condition:
		failures += 1

func _run() -> void:
	var packed: PackedScene = load("res://level_1.tscn")
	_check("main scene resource loads", packed != null)
	_check("phase selector scene and script load", load("res://phase_select.tscn") != null)
	if packed == null:
		quit(1)
		return
	var level: Node = packed.instantiate()
	root.add_child(level)
	for frame in range(12):
		await physics_frame
	var finn: CharacterBody2D = level.get_node("Players/Finn")
	var jake: CharacterBody2D = level.get_node("Players/Jake")
	var bridge: Node = level.get_node("JakeBridge")
	var lever: Node = level.get_node("Lever")
	var checkpoint: Node = level.get_node("Checkpoint")
	var fall_zone: Node = level.get_node("FallZone")
	var trunk: Node = level.get_node("TrunkPuzzle")
	var coop: Node = level.get_node("TwoPlayerPuzzle")
	var crystal: Node = level.get_node("FriendshipCrystal")
	var exit_area: Node = level.get_node("CooperativeExit")
	var camera: Camera2D = level.get_node("SharedCamera")
	var backdrop: Parallax2D = level.get_node("BackgroundParallax")
	_check("bridge child refs resolve", bridge.activation_area != null and bridge.bridge_body != null)
	_check("two-player puzzle refs resolve", coop.player_one_plate != null and coop.player_two_plate != null and coop.gate_to_open != null)
	_check("lever target resolves", lever.gate_to_open != null)
	_check("fall-zone player and checkpoint refs resolve", fall_zone.finn == finn and fall_zone.jake == jake and fall_zone.checkpoint == checkpoint)
	_check("shared camera targets resolve", camera.player_a == finn and camera.player_b == jake)
	_check("background extends the supplied treehouse art without repeating the full image", backdrop.get_child_count() == 1 and backdrop.scroll_scale.x < 1.0 and backdrop.get_child(0).scale.x > 3.0 and backdrop.get_child(0).material is ShaderMaterial)
	_check("Jake sprite is centered to match Finn's baseline", is_zero_approx(jake.animated_sprite.position.y))
	_check("fall zone spans the playable map", fall_zone.get_node("CollisionShape2D").shape.size.x >= 2176.0)
	_check("closed trunk gate sprite rests on the ground line", is_equal_approx(trunk.get_node("Gate/Sprite2D").position.y, 8.0))
	_check("checkpoint flag is lifted above its floor anchor", checkpoint.get_node("Sprite2D").position.y < -24.0 and checkpoint.get_node("Sprite2D").scale.x > 1.0)
	_check("HUD labels have a readable backplate", level.get_node("HUD/HUDBackplate") != null and level.get_node("HUD").get_child(0).name == "HUDBackplate")
	root.size = Vector2i(1024, 768)
	await process_frame
	_check("game HUD remains inside a 4:3 viewport", level.get_node("HUD/HUDBackplate").position.x + level.get_node("HUD/HUDBackplate").size.x <= root.size.x)
	root.size = Vector2i(1152, 648)
	await process_frame
	var orphaned_cells := 0
	for cell in (level.get_node("TileMap") as TileMap).get_used_cells(0):
		if cell.y < 13:
			orphaned_cells += 1
	_check("orphaned floating terrain cells are removed from the route", orphaned_cells == 0)
	_check("existing grass assets are placed once along the route", level.get_node("Scenery/GeneratedGrass").get_child_count() == 16)
	var start_floor_is_continuous := true
	for cell_x in range(0, 8):
		for cell_y in range(14, 20):
			if (level.get_node("TileMap") as TileMap).get_cell_source_id(0, Vector2i(cell_x, cell_y)) < 0:
				start_floor_is_continuous = false
	_check("starting ground is filled continuously to the left map edge", start_floor_is_continuous)
	var gap_is_clear := true
	for cell_x in [14, 18]:
		for cell_y in range(13, 20):
			if (level.get_node("TileMap") as TileMap).get_cell_source_id(0, Vector2i(cell_x, cell_y)) >= 0:
				gap_is_clear = false
	_check("first gap cannot be bypassed on leftover grass tiles", gap_is_clear)
	finn.global_position.x = 1000.0
	jake.global_position.x = 300.0
	_check("players cannot walk far enough apart to leave the shared view", is_zero_approx(finn._limit_direction_from_partner(1.0)))
	finn.global_position = Vector2(256.0, 245.0)
	jake.global_position = Vector2(300.0, 245.0)
	for frame in range(12): await physics_frame
	_check("both players land on the start platform", finn.is_on_floor() and jake.is_on_floor())
	var finn_hitbox := finn.get_node("CollisionShape2D") as CollisionShape2D
	var jake_hitbox := jake.get_node("CollisionShape2D") as CollisionShape2D
	var finn_box := finn_hitbox.shape as RectangleShape2D
	var jake_box := jake_hitbox.shape as RectangleShape2D
	var finn_feet := finn_hitbox.position.y + finn_box.size.y * 0.5
	var jake_feet := jake_hitbox.position.y + jake_box.size.y * 0.5
	_check("Finn and Jake hitboxes meet the ground at the same baseline", absf(finn_feet - jake_feet) < 0.1 and absf(finn.global_position.y - jake.global_position.y) < 2.0)
	finn.global_position = Vector2(40.0, 245.0)
	jake.global_position = Vector2(300.0, 245.0)
	Input.action_press("p1_left")
	for frame in range(45): await physics_frame
	Input.action_release("p1_left")
	_check("start platform extends safely to its left boundary wall", finn.global_position.x >= 8.0 and finn.is_on_floor())
	finn.global_position = Vector2(2140.0, 245.0)
	jake.global_position = Vector2(2090.0, 245.0)
	Input.action_press("p1_right")
	for frame in range(30): await physics_frame
	Input.action_release("p1_right")
	_check("right boundary wall keeps players inside the level", finn.global_position.x < 2172.0 and finn.is_on_floor())
	finn.global_position = Vector2(256.0, 245.0)
	jake.global_position = Vector2(300.0, 245.0)
	for frame in range(12): await physics_frame
	var finn_x := finn.global_position.x
	var jake_x := jake.global_position.x
	Input.action_press("p1_right")
	for frame in range(20):
		await physics_frame
	Input.action_release("p1_right")
	_check("Finn movement input moves Finn", finn.global_position.x > finn_x + 20.0)
	_check("Finn movement input does not move Jake", absf(jake.global_position.x - jake_x) < 2.0)
	var jump_event := InputEventKey.new()
	jump_event.physical_keycode = KEY_SPACE
	jump_event.pressed = true
	Input.parse_input_event(jump_event)
	for frame in range(2): await physics_frame
	var jumped := finn.velocity.y < 0.0
	jump_event.pressed = false
	Input.parse_input_event(jump_event)
	_check("Finn jump input produces upward velocity", jumped)
	jake.global_position = Vector2(448.0, 245.0)
	for frame in range(12): await physics_frame
	_check("Jake is grounded before using the anchor", jake.is_on_floor())
	Input.action_press("p2_ability")
	for frame in range(2): await process_frame
	_check("Jake begins extension without invisible support", bridge.bridge_body.collision_layer == 0 and jake.movement_locked)
	_check("Jake uses the supplied bridge extension animation", jake.animated_sprite.animation == &"bridge_extend" or jake.animated_sprite.animation == &"bridge_hold")
	for frame in range(100): await physics_frame
	_check("complete rendered bridge enables support", bridge.bridge_body.collision_layer == 1 and bridge.bridge_visual.has_full_render())
	finn.global_position = Vector2(400.0, 245.0)
	finn.velocity = Vector2.ZERO
	for frame in range(12): await physics_frame
	Input.action_press("p1_right")
	Input.action_press("p1_jump")
	await physics_frame
	Input.action_release("p1_jump")
	for frame in range(90): await physics_frame
	Input.action_release("p1_right")
	for frame in range(8): await physics_frame
	_check("Finn crosses the first gap on Jake's active bridge", finn.global_position.x > 620.0 and finn.is_on_floor())
	Input.action_release("p2_ability")
	for frame in range(100): await physics_frame
	_check("releasing Jake ability retracts bridge and unlocks him", bridge.bridge_body.collision_layer == 0 and not jake.movement_locked and jake.animated_sprite.animation == &"idle")
	finn.global_position = Vector2(660.0, 248.0)
	for frame in range(3): await physics_frame
	Input.action_press("p1_interact")
	await process_frame
	if Input.is_action_just_pressed("p1_interact"): lever._process(0.016)
	Input.action_release("p1_interact")
	_check("Finn lever opens permanent bridge", level.get_node("PermanentBridge").collision_layer == 1)
	finn.global_position = Vector2(800.0, 250.0)
	for frame in range(3): await physics_frame
	_check("checkpoint activates on player contact", checkpoint.activated)
	finn.global_position = Vector2(1100.0, 560.0)
	for frame in range(4): await physics_frame
	_check("fall zone respawns both players at separate safe markers", finn.global_position.distance_to(jake.global_position) > 20.0 and finn.global_position.y < 300.0 and jake.global_position.y < 300.0)
	var plate: Area2D = trunk.get_node("Plate")
	var log: AnimatableBody2D = trunk.get_node("Log")
	var gate: CoopGate = trunk.get_node("Gate")
	var initial_log_position := log.global_position
	var log_hitbox := log.get_node("CollisionShape2D") as CollisionShape2D
	_check("trunk hitbox bottom is aligned with the platform surface", absf(log.global_position.y + (log_hitbox.shape as RectangleShape2D).size.y * 0.5 - 282.0) < 2.0)
	_check("trunk plate's trigger overlaps the trunk collision at its real height", plate.get_node("CollisionShape2D").shape.size.y >= 24.0 and absf(log.global_position.y - plate.global_position.y) < 24.0)
	finn.global_position = log.global_position + Vector2(-50.0, -13.0)
	finn._facing = 1.0
	for frame in range(3): await physics_frame
	var log_start := log.global_position
	Input.action_press("p1_right")
	Input.action_press("p1_ability")
	for frame in range(75): await physics_frame
	Input.action_release("p1_right")
	Input.action_release("p1_ability")
	for frame in range(3): await physics_frame
	_check("Finn pushes the trunk from its actual start position onto the plate", log.global_position.x > initial_log_position.x + 70.0 and gate.is_open)
	_check("trunk remains on the ground while it moves", absf(log.global_position.y - initial_log_position.y) < 2.0)
	_check("gate collider is disabled after the pressure plate opens it", gate.get_node("CollisionShape2D").disabled)
	finn.global_position = log.global_position + Vector2(-32.0, 0.0)
	Input.action_press("p1_reset")
	for frame in range(1): await physics_frame
	Input.action_release("p1_reset")
	_check("R restores the trunk and the solved gate stays open", log.global_position.distance_to(initial_log_position) < 2.0 and gate.is_open)
	finn.global_position = Vector2(gate.global_position.x - 60.0, 245.0)
	Input.action_press("p1_right")
	for frame in range(40): await physics_frame
	Input.action_release("p1_right")
	_check("Finn can physically walk through the first gate after solving the trunk plate", finn.global_position.x > gate.global_position.x + 35.0)
	var finn_plate: Node2D = coop.get_node("FinnPlate")
	var jake_plate: Node2D = coop.get_node("JakePlate")
	finn.global_position = finn_plate.global_position + Vector2(0.0, -24.0)
	for frame in range(3): await physics_frame
	_check("one player alone cannot solve the two-plate puzzle", not coop.solved)
	jake.global_position = jake_plate.global_position + Vector2(0.0, -24.0)
	for frame in range(6): await physics_frame
	_check("both assigned players solve and latch the two-plate gate", coop.solved and coop.gate_to_open.is_open)
	finn.global_position = Vector2(800.0, 250.0)
	jake.global_position = Vector2(840.0, 250.0)
	for frame in range(3): await physics_frame
	_check("two-plate gate stays open after both players leave", coop.gate_to_open.is_open)
	finn.global_position = crystal.global_position
	for frame in range(5): await physics_frame
	_check("crystal pickup updates HUD once", level.get_node("HUD/CrystalStatus").text == "Cristal da Amizade recuperado!")
	finn.global_position = Vector2(2110.0, 245.0)
	jake.global_position = Vector2(1900.0, 245.0)
	for frame in range(3): await physics_frame
	_check("one player alone cannot finish at the exit", not exit_area._completed)
	finn.global_position = Vector2(1900.0, 245.0)
	jake.global_position = Vector2(2110.0, 245.0)
	for frame in range(3): await physics_frame
	_check("exit removes a player after they leave the area", not exit_area._completed)
	finn.global_position = Vector2(2110.0, 245.0)
	for frame in range(6): await physics_frame
	_check("cooperative exit completes only with crystal and both players", exit_area._completed and exit_area.completion_label.visible and level.get_node("HUD/ReturnToPhases").visible)
	print("Smoke check failures: ", failures)
	level.queue_free()
	for frame in range(4): await process_frame
	# Let short puzzle SFX finish before shutting down the headless test tree.
	await create_timer(1.0).timeout
	packed = null
	level = null
	jump_event = null
	finn = null
	jake = null
	bridge = null
	lever = null
	checkpoint = null
	fall_zone = null
	trunk = null
	coop = null
	crystal = null
	exit_area = null
	camera = null
	backdrop = null
	plate = null
	log = null
	finn_plate = null
	jake_plate = null
	quit(0 if failures == 0 else 1)
