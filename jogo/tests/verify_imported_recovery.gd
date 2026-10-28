extends "res://tests/verify_imported_levels.gd"

func send_key(key: Key) -> void:
	var event:=InputEventKey.new()
	event.keycode=key;event.pressed=true
	Input.parse_input_event(event)
	await frames(3)
	event=InputEventKey.new();event.keycode=key;event.pressed=false
	Input.parse_input_event(event)
	await frames(3)

func fall_pair(a: CoopPlayer,b: CoopPlayer) -> void:
	a.position=Vector2(300,603);b.position=Vector2(340,603)
	a.velocity=Vector2.ZERO;b.velocity=Vector2.ZERO
	await frames(24)

func run() -> void:
	root.size=viewport_size
	for number in [3,4]:
		await open_level(number)
		var a: CoopPlayer=level.marceline if number==3 else level.finn
		var b: CoopPlayer=level.bmo
		var checkpoint: CoopCheckpoint=level.get_node("Checkpoint")
		var fall: CoopFallZone=level.get_node("FallZone")
		# Isolated recovery fixtures; these placements are not route completion evidence.
		await fall_pair(a,b)
		check("%d: early simultaneous fall recovers once at original side"%number,fall.recovery_count==1 and not fall._used_checkpoint and a.position.x<400 and b.position.x<400 and a.is_on_floor() and b.is_on_floor())
		check("%d: returns visible separate unlocked pair"%number,a.visible and b.visible and not a.movement_locked and not b.movement_locked and absf(a.position.x-b.position.x)>30)
		var cp_x:=checkpoint.position.x
		a.position=Vector2(cp_x+78,330);b.position=Vector2(cp_x+118,330)
		await frames(20);await walk(a,cp_x)
		check("%d: reaching marker without prior gate cannot earn checkpoint"%number,not checkpoint.activated)
		await walk(a,cp_x+78)
		var gate: CoopGate=level.get_node("MusicGate" if number==3 else "TrunkPuzzle/Gate")
		gate.open_gate()
		await frames(4);await walk(a,cp_x)
		check("%d: checkpoint accepts fresh entry after prior gate"%number,checkpoint.activated)
		await fall_pair(a,b)
		check("%d: checkpoint returns to its separated safe markers"%number,fall.recovery_count==2 and fall._used_checkpoint and a.position.x>cp_x-62 and b.position.x>cp_x-22 and a.is_on_floor() and b.is_on_floor())
		check("%d: recovery preserves solved gate and checkpoint"%number,gate.is_open and checkpoint.activated and not b.movement_locked)
		if number==3:
			b.position=Vector2(1040,330);a.position=Vector2(960,330)
			await frames(20);await tap(b,"interact")
			check("3: terminal opens in recovery fixture",level.symbol_terminal.panel_open)
			var before:=a.position.x
			await walk(a,920)
			check("3: partner still moves while BMO operates",a.position.x<before-20 and b.movement_locked)
			await send_key(KEY_ESCAPE)
			check("3: Escape closes panel and releases BMO",not level.symbol_terminal.panel_open and not b.movement_locked)
			await tap(b,"interact")
			await fall_pair(a,b)
			check("3: fall with panel open cancels input capture",not level.symbol_terminal.panel_open and not b.movement_locked and b.interaction_owner==null)
			b.position=Vector2(1040,330);await frames(20);await tap(b,"interact")
			check("3: panel can reopen after fall",level.symbol_terminal.panel_open)
		await send_key(KEY_F2)
		level=current_scene
		await frames(24)
		check("%d: F2 restarts scene with initial progress"%number,level.completion_count==0 and not level.get_node("Checkpoint").activated and not level.bmo.movement_locked and level.bmo.interaction_owner==null)
	# Menu navigation uses actual scene changes and button signals.
	for number in [3,4]:
		release()
		if is_instance_valid(level): stop_test_audio(level)
		change_scene_to_file("res://phase_select.tscn")
		await frames(10)
		var menu := current_scene
		var button: Button=menu.get_node("Design/Phase%d"%number)
		check("menu: phase %d button available"%number,not button.disabled)
		button.pressed.emit()
		await frames(24);level=current_scene
		check("menu: button opens phase %d"%number,level.scene_file_path=="res://level_%d.tscn"%number)
		level.get_node("HUD/ReturnToPhases").pressed.emit()
		await frames(10)
		check("menu: phase %d return works"%number,current_scene.scene_file_path=="res://phase_select.tscn")
	await finish("Imported recovery/menu")
