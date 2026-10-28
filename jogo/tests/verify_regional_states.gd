extends "res://tests/journey_driver.gd"
## Prepared state fixtures; these checks are not route-completion evidence.
func open(number: int) -> void:
	release()
	if is_instance_valid(level):stop_test_audio(level);level.queue_free();await frames(4)
	level=load("res://level_%d.tscn"%number).instantiate();root.add_child(level);current_scene=level;await frames(30)
func key(code: Key) -> void:
	var e:=InputEventKey.new();e.keycode=code;e.pressed=true;Input.parse_input_event(e);await frames(3)
	e=InputEventKey.new();e.keycode=code;e.pressed=false;Input.parse_input_event(e);await frames(3)
func run() -> void:
	await open(2)
	var a=level.cake;var b=level.fionna
	a.position=Vector2(300,742);b.position=Vector2(350,744);await frames(12)
	check("ice simultaneous fall returns once to safe start",level.recovery_count==1 and a.position.x<300 and b.position.x<300 and a.is_on_floor() and b.is_on_floor())
	# Early finish-area arrival cannot bypass the bridge/crank flow.
	a.position=Vector2(2112,487);b.position=Vector2(2192,487);await frames(10)
	check("ice cannot collect or finish before mechanisms",not level.crystal_collected and not level.completed)
	level.first_crank.solved=true;level.get_node("FirstPlatform").extended=true
	a.position=Vector2(1024,487);b.position=Vector2(1088,487);await frames(6)
	check("ice checkpoint earned only after solved approach and reunion",level.checkpoint_active)
	level.crank.solved=true;level.get_node("ExtendPlatform").extended=true
	a.position=Vector2(2112,487);b.position=Vector2(2040,487);await frames(15)
	check("ice collects crystal without one-player completion",level.crystal_collected and not level.completed)
	a.position=Vector2(300,742);b.position=Vector2(350,744);await frames(12)
	check("ice recovery preserves crystal and solved passages",level.crystal_collected and level.crank.solved and level.first_crank.solved and a.position.x>1000 and b.position.x>1000)
	await key(KEY_F2);level=current_scene;await frames(20)
	check("ice full restart clears crystal checkpoint and completion",not level.crystal_collected and not level.completed and not level.checkpoint_active)
	await open(4)
	a=level.finn;b=level.bmo
	# Place block on the physical rail and operator in range to isolate cancellation.
	level.get_node("TrunkPuzzle/Log").global_position=Vector2(544,374)
	b.position=Vector2(376,352);a.position=Vector2(300,352);await frames(12)
	await tap(b,"interact");await key(KEY_ESCAPE);await frames(5)
	check("workshop cancels transport connection without movement",not b.movement_locked and not level.transport_terminal.pending and not level.carrier.requested)
	a.position=Vector2(712,356);a.movement_locked=true
	await tap(b,"interact");await frames(220)
	check("workshop waits instead of carrying block through partner",level.carrier.blocked and not level.carrier.arrived and a.position.x>700)
	a.movement_locked=false;await walk(a,840);await frames(160)
	check("workshop repeated attempt transports once safely",level.carrier.arrived and level.transport_terminal.activation_count==1 and not b.movement_locked)
	level.get_node("TrunkPuzzle/Log").reset_to_start();await frames(8)
	check("workshop local block reset restores unsolved rail",not level.carrier.arrived and not level.carrier.requested and not level.transport_terminal.energized)
	# Wrong conduit geometry does not grant energy progress.
	b.position=Vector2(1320,352);a.position=Vector2(1200,352);await frames(12)
	await tap(b,"interact");await frames(90)
	check("workshop refuses energy until physical shapes align",not level.energy_terminal.energized and not level.energy_gate.is_open and not b.movement_locked)
	await key(KEY_F2);level=current_scene;await frames(20)
	check("workshop restart clears rail and connections",not level.carrier.arrived and not level.connections.solved() and not level.bmo.movement_locked)
	await finish("Regional recovery and cancellation fixtures")
