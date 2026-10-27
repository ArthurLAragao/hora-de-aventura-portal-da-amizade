extends "res://tests/journey_driver.gd"
## All repositioning below is explicitly isolated fixture setup, never route evidence.
const Build=preload("res://journey_build.gd")

func place(actor: Node2D,at: Vector2,n: int=16) -> void:
	actor.position=at
	if actor is CoopPlayer: actor.velocity=Vector2.ZERO
	await frames(n)

func key(code: Key) -> void:
	var event:=InputEventKey.new()
	event.keycode=code
	event.pressed=true
	level._unhandled_key_input(event)
	await frames(5)

func fall_one(actor: CoopPlayer) -> void:
	var before: int=level.fall.recovery_count
	await place(actor,Vector2(712,530),1)
	await until(func():return level.fall.recovery_count>before,150)
	await frames(8)

func phase1_cases(slot: int) -> void:
	await fresh("res://level_1.tscn",slot,"finn_player_id")
	await fall_one(level.finn)
	check("fixture: early fall returns BOTH to initial safe ground",level.fall.recovery_count==1 and level.finn.position.distance_to(Vector2(128,370.35))<2 and level.jake.position.distance_to(Vector2(192,370.35))<2 and not level.checkpoint.activated)
	await place(level.finn,Vector2(1056,329.85))
	check("fixture: checkpoint refuses unearned arrival",not level.checkpoint.activated)
	await fall_one(level.finn)
	check("fixture: unearned marker never becomes respawn",level.finn.position.x<200 and level.jake.position.x<240 and not level.checkpoint.activated)
	await place(level.finn,Vector2(600,369.85))
	var count: int=level.fall.recovery_count
	Input.action_press(action(level.finn,"right"))
	Input.action_press(action(level.finn,"jump"))
	await frames(2)
	Input.action_release(action(level.finn,"jump"))
	await until(func():return level.fall.recovery_count>count,160)
	release()
	await frames(8)
	check("fixture: ordinary jump does not replace Jake over raised gap",level.fall.recovery_count==count+1 and not level.permanent.visible and not level.checkpoint.activated)
	await place(level.finn,Vector2(866,329.85))
	await tap(level.finn,"interact")
	await place(level.jake,Vector2(950,329.85))
	await walk(level.finn,1048)
	check("fixture: fresh checkpoint entry requires repaired passage",level.permanent.visible and level.checkpoint.activated)
	await place(level.log,Vector2(1480,347.35),2)
	await fall_one(level.finn)
	check("fixture: grounded unresolved log keeps useful position after fall",absf(level.log.position.x-1480)<1.0)
	await place(level.log,Vector2(1024,347.35),2)
	await fall_one(level.finn)
	check("fixture: obstructing unresolved log restored without erasing passage",level.fall._used_checkpoint and level.log.position.x==1360 and level.permanent.visible and level.finn.position.x>1000 and not level.finn.movement_locked and not level.jake.movement_locked)
	await place(level.jake,Vector2(1856,249.85))
	await place(level.log,Vector2(1848,347.35))
	await frames(8)
	check("fixture: final combination latches permanently",level.relay_solved and level.final_gate.is_open)
	await place(level.finn,Vector2(2224,329.85))
	await frames(30)
	check("fixture: first crystal records a single collection",level.crystal_count==1)
	await fall_one(level.finn)
	check("fixture: fall preserves final gate, checkpoint and crystal",level.relay_solved and level.final_gate.is_open and level.crystal_count==1 and level.exit_area._crystal_collected and not level.exit_area._completed)
	var previous: int=level.fall.recovery_count
	level.finn.position=Vector2(704,530)
	level.jake.position=Vector2(736,530)
	await until(func():return level.fall.recovery_count>previous,150)
	await frames(15)
	check("fixture: near-simultaneous falls enqueue one pair recovery",level.fall.recovery_count==previous+1 and level.finn.is_on_floor() and level.jake.is_on_floor())
	await key(KEY_F2)
	await frames(20)
	level=current_scene
	check("F1 complete restart clears puzzles/crystal and keeps swapped controls",not level.relay_solved and not level.tutorial_solved and level.crystal_count==0 and not level.checkpoint.activated and level.finn.player_id==slot)

func fixture_stage(index: int,slot: int) -> void:
	await fresh("res://level_6.tscn",slot,"primary_player_id")
	if index>=1:
		await place(level.log,Vector2(736,level.FLOOR-15),3)
		level._repair(0)
		level._advance_pair(1)
		await until(func():return level.stage==1 and not level._transitioning)
	if index>=2:
		level._repair(1)
		level._advance_pair(2)
		await until(func():return level.stage==2 and not level._transitioning)
	await frames(10)

func phase6_cases(slot: int) -> void:
	for index in [0,1,2]:
		await fixture_stage(index,slot)
		var before: int=level.recovery_count
		level.pair[0].position.y=780
		level.pair[1].position.y=780
		await until(func():return level.recovery_count>before and not level._recovering)
		await frames(15)
		check("fixture F6 sector %d: fall restores correct pair/roles and preserves repairs"%index,level.stage==index and level.checkpoint_stage==index and level.recovery_count==before+1 and level.pair[0].player_id==slot and level.pair[1].player_id==3-slot and level.pair.all(func(a):return a.is_on_floor() and a.visible and not a.movement_locked) and get_nodes_in_group("players").size()==2 and (index==0 or level.permanent.visible))
		await key(KEY_F2)
		await frames(25)
		level=current_scene
		check("F6 restart during sector %d returns to initial duo/progress, preserving configured roles"%index,level.stage==0 and level.repaired==[false,false,false] and level.pair[0].character_id==&"finn" and level.pair[0].player_id==slot)
	await fixture_stage(0,slot)
	await place(level.pair[1],Vector2(444,469.85))
	Input.action_press(action(level.pair[1],"ability"))
	await frames(3)
	await key(KEY_ESCAPE)
	release()
	await frames(120)
	check("fixture: early bridge cancel restores controls/no invisible floor",level.bridge.state==level.bridge.State.IDLE and not level.pair[1].movement_locked and level.pair[1].animated_sprite.visible and not level.bridge._bridge_active)
	await fixture_stage(1,slot)
	var cake: CoopPlayer=level.pair[1]
	var fionna: CoopPlayer=level.pair[0]
	await place(cake,Vector2(804,level.FLOOR-32.5))
	await tap(cake,"interact")
	await walk(cake,900)
	check("fixture: Cake cannot stand up during a real crawl under the roof",not cake.call("can_stand"))
	await place(fionna,Vector2(896,level.FLOOR-112.5))
	check("fixture: crank refuses before Cake's tunnel/switch",not level.crank.call("interact",fionna) and not level.mechanism_unlocked)
	level.mechanism_unlocked=true
	level.crank.monitoring=true
	await frames(4)
	await tap(fionna,"interact")
	await frames(4)
	await key(KEY_ESCAPE)
	check("fixture: crank cancellation restores local controls and coherent retry",not fionna.movement_locked and not level.crank.get("pending") and not level.crank.get("solved"))
	await tap(fionna,"interact")
	fionna.animated_sprite.stop()
	await frames(100)
	check("fixture: interrupted crank animation cancels safely without awarding progress",not fionna.movement_locked and not level.crank.get("solved") and not level.crank.get("pending"))
	await fixture_stage(2,slot)
	var bmo: CoopPlayer=level.pair[1]
	var marceline: CoopPlayer=level.pair[0]
	await place(bmo,Vector2(568,458.5))
	check("fixture: BMO cannot guess symbols before clue or use music capability",not level.terminal.call("interact",bmo) and not level.music.call("activate",bmo))
	level.receiver.open_gate()
	await frames(8)
	await tap(bmo,"interact")
	check("fixture: opening interaction never enters first symbol",level.terminal.get("panel_open") and level.terminal.get("entered").is_empty())
	await key(KEY_ESCAPE)
	check("fixture: terminal cancel unblocks only operator",not bmo.movement_locked and not level.terminal.get("panel_open") and not marceline.movement_locked)
	await tap(bmo,"interact")
	for i in 3: await tap(bmo,"interact")
	check("fixture: wrong sequence is retryable and cannot repair signal",not level.repaired[2] and level.terminal.get("attempts")==1 and level.terminal.get("entered").is_empty() and level.terminal.get("panel_open"))
	for a in ["right","right","interact","right","interact","right","interact"]: await tap(bmo,a)
	check("fixture: correct retry activates signal once",level.repaired[2] and level.terminal.get("activation_count")==1 and not bmo.movement_locked)
	await tap(bmo,"interact")
	check("fixture: repeated interaction is idempotent",level.terminal.get("activation_count")==1 and not bmo.movement_locked)
	await place(marceline,Vector2(512,458.5))
	check("fixture: one confirmation alone cannot reveal crystal",not level.confirmed and not level.crystal.visible)
	await place(bmo,Vector2(784,437.85))
	await frames(8)
	check("fixture: both confirmations required before crystal",level.confirmed and level.crystal_count==0)
	await place(bmo,Vector2(640,437.85))
	await frames(20)
	check("fixture: portal refuses single player even with sixth crystal",level.crystal_count==1 and level.completion_count==0)
	var before: int=level.recovery_count
	level.pair[0].position.y=780
	await until(func():return level.recovery_count>before and not level._recovering)
	await frames(16)
	check("fixture: C recovery retains crystal, seals and current pair",level.stage==2 and level.repaired==[true,true,true] and level.crystal_count==1 and level.exit_area._crystal_collected and not level.exit_area._completed and not level.pair[0].get("is_floating") and not level.terminal.get("panel_open"))

func bridge_recovery_cases(slot: int) -> void:
	for scene in [1,6]:
		for phase in ["approach","source","growth","hold","pending","shrink","reverse"]:
			await fresh("res://level_%d.tscn"%scene,slot,"finn_player_id" if scene==1 else "primary_player_id")
			var owner: CoopPlayer=level.jake if scene==1 else level.pair[1]
			var friend: CoopPlayer=level.finn if scene==1 else level.pair[0]
			if scene==1:
				level.tutorial_solved=true
				level.bridge.process_mode=Node.PROCESS_MODE_INHERIT
			var anchor_x: float=600 if scene==1 else 400
			var floor_y: float=402.35286 if scene==1 else level.LEFT_FLOOR
			await place(owner,Vector2(anchor_x,floor_y-32.5))
			Input.action_press(action(owner,"ability"))
			await frames(3)
			if phase=="source": await until(func():return level.bridge.state==JakeBridge.State.EXTENDING and level.bridge.step==JakeBridge.Step.SOURCE_EXTEND)
			if phase not in ["approach","source"]: await until(func():return level.bridge.step==JakeBridge.Step.GROW)
			if phase in ["hold","pending","shrink","reverse"]: await until(func():return level.bridge._bridge_active)
			if phase=="pending":
				await place(friend,Vector2(anchor_x+72,floor_y-43.35))
				Input.action_release(action(owner,"ability"))
				await frames(4)
			elif phase in ["shrink","reverse"]:
				Input.action_release(action(owner,"ability"))
				await until(func():return level.bridge.step==JakeBridge.Step.SHRINK)
				if phase=="reverse": await until(func():return level.bridge.step==JakeBridge.Step.SOURCE_RETRACT)
			var before: int=level.fall.recovery_count if scene==1 else level.recovery_count
			# Isolated fall setup only; never accepted as a normal crossing.
			var falling: CoopPlayer=owner if phase=="pending" else friend
			falling.position=Vector2(anchor_x+72,680 if scene==1 else 780)
			await until(func():return (level.fall.recovery_count if scene==1 else level.recovery_count)>before)
			release()
			await frames(20)
			check("fixture F%d: fall during %s clears support, sprite and both local controls"%[scene,phase],level.bridge.state==JakeBridge.State.IDLE and not level.bridge._bridge_active and level.bridge.bridge_body.collision_layer==0 and not owner.movement_locked and not friend.movement_locked and owner.animated_sprite.visible and friend.animated_sprite.visible and owner.is_on_floor() and friend.is_on_floor())

func exits_without_crystal(slot: int) -> void:
	await fresh("res://level_1.tscn",slot,"finn_player_id")
	await place(level.finn,Vector2(2336,329.85))
	await place(level.jake,Vector2(2304,329.85))
	await frames(5)
	check("fixture F1: both players at exit cannot finish without crystal/puzzle",level.exit_area._players_in_exit.size()==2 and not level.exit_area._completed and level.completion_count==0 and level.crystal_count==0)
	await fixture_stage(2,slot)
	await place(level.pair[0],Vector2(624,437.85))
	await place(level.pair[1],Vector2(656,437.85))
	await frames(5)
	check("fixture F6: both at portal cannot skip final signal/confirmation/crystal",level.exit_area._players_in_exit.size()==2 and not level.exit_area._completed and level.completion_count==0 and level.crystal_count==0)

func run() -> void:
	for slot in [1,2]:
		await phase1_cases(slot)
		await phase6_cases(slot)
		await bridge_recovery_cases(slot)
		await exits_without_crystal(slot)
	await finish("Journey isolated safety")
