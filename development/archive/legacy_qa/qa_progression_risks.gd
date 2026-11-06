extends "res://tests/journey_driver.gd"
## Explicit setups are isolated state tests, never evidence of traversing a puzzle.
func key(code: Key) -> void:
	var event:=InputEventKey.new()
	event.keycode=code
	event.pressed=true
	level._unhandled_key_input(event)
	await frames(5)

func log_cases(slot: int) -> void:
	await fresh("res://level_1.tscn",slot,"finn_player_id")
	await walk(level.finn,260)
	await push_until(level.finn,func():return level.tutorial_solved)
	var socket: Vector2=level.tutorial_log.position
	Input.action_press(action(level.finn,"right"))
	await frames(180)
	Input.action_release(action(level.finn,"right"))
	check("normal inputs: tutorial log settles into its socket instead of floating over the gap",level.tutorial_log.settled and level.tutorial_log.position.distance_to(socket)<0.1 and socket.x<480 and not level.permanent.visible and level.fall.recovery_count==0)
	await capture("log-socket-bypass-fixed")
	# Isolated unsolved object at the bank edge: support rule prevents a floating step.
	level.log.position=Vector2(664,level.tutorial_log.position.y)
	level.log.push(1)
	await frames(2)
	check("isolated log cannot be pushed onto unsupported void",level.log.position.x==664 and level.log.blocked_by_edge)
	level.log.position=Vector2(1480,347.35286)
	# Occupy original reset destination: no reset into a character.
	level.finn.position=Vector2(1360,329.85)
	level.finn.velocity=Vector2.ZERO
	await frames(8)
	level.log.reset_to_start()
	await frames(5)
	check("reset waits while its destination is occupied",level.log.reset_pending and level.log.position.x==1480)
	await walk(level.finn,1300)
	await frames(8)
	check("reset completes after the player leaves, without trapping either body",not level.log.reset_pending and level.log.position.x==1360 and not level.finn.movement_locked)

func signal_and_handoff(slot: int) -> void:
	await fresh("res://level_6.tscn",slot,"primary_player_id")
	# Earned-state fixture for testing transition with held input.
	level.log.position=Vector2(736,level.FLOOR-15)
	await frames(3)
	level._repair(0)
	var old: CoopPlayer=level.pair[0]
	Input.action_press(action(old,"right"))
	Input.action_press(action(old,"interact"))
	level._advance_pair(1)
	await until(func():return level.stage==1)
	await frames(35)
	print("PROBE handoff ",level._transitioning," ",level.pair[0].position," ",level.pair[1].position," locks ",level.pair[0].movement_locked,"/",level.pair[1].movement_locked," floors ",level.pair[0].is_on_floor(),"/",level.pair[1].is_on_floor()," crawl ",level.pair[1].crawling)
	check("held input during handoff keeps new Cake/Fionna local controls locked",level._transitioning and level.pair.all(func(a):return a.movement_locked and a.is_on_floor()) and not level.pair[1].crawling and level.pair[0].position.x==624 and level.pair[1].position.x==672)
	release()
	await until(func():return not level._transitioning)
	check("release hands control to exactly the new pair and updates camera",not level.pair[0].movement_locked and not level.pair[1].movement_locked and get_nodes_in_group("players").size()==2 and level.camera.player_a==level.pair[0])
	level._repair(1)
	level._advance_pair(2)
	await until(func():return level.stage==2 and not level._transitioning)
	var m: CoopPlayer=level.pair[0]
	await jump(m,56)
	await jump(m,158)
	await walk(m,182)
	await jump(m,416,false)
	check("normal jump cannot replace the float gap",m.position.y>440 and not level.clue_revealed)
	await tap(m,"interact")
	check("music refuses interaction from the ground below its shelf",not level.clue_revealed and not level.music.can_play(m))
	# Grounded capability is also required: no jump-activation from below.
	m.position=Vector2(416,level.LEFT_FLOOR-60)
	m.velocity=Vector2(0,-80)
	await frames(2)
	check("airborne music attempt cannot reveal the clue",not level.music.activate(m) and not level.clue_revealed)
	await key(KEY_F2)
	await frames(25)
	level=current_scene
	check("full restart after a handoff clears repairs and action locks",level.stage==0 and level.repaired==[false,false,false] and level.pair.all(func(a):return a.is_on_floor() and not a.movement_locked))
	level._advance_pair(1)
	await frames(3)
	await key(KEY_F2)
	await frames(35)
	level=current_scene
	check("restart during fade leaves initial pair and no abandoned input owner",level.stage==0 and not level._transitioning and get_nodes_in_group("players").size()==2 and level.pair.all(func(a):return not a.movement_locked))

func run() -> void:
	root.size=viewport_size
	for slot in [1,2]:
		await log_cases(slot)
		await signal_and_handoff(slot)
	await finish("QA progression risks")
