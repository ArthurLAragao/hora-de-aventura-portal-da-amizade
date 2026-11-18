extends SceneTree
## Fixture placement isolates recovery states; only _progress_route proves gameplay progression.

var failures := 0
var checks: Array[Dictionary] = []
var level: Node2D
var finn: CoopPlayer
var jake: CoopPlayer
var bridge: JakeBridge
var checkpoint: CoopCheckpoint
var fall: CoopFallZone
var role := 2
var activations := 0
var starts: Array[Dictionary] = []
var returns: Array[bool] = []
var capture_dir := ""
var report_path := ""

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="): capture_dir=argument.trim_prefix("--capture-dir=")
		if argument.begins_with("--report="): report_path=argument.trim_prefix("--report=")
	call_deferred("_run")

func _check(label: String, condition: bool) -> void:
	checks.append({"check":label,"passed":condition})
	print(("PASS " if condition else "FAIL ")+label)
	if not condition: failures+=1

func _frames(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame

func _until(predicate: Callable, limit: int=300) -> bool:
	for i in limit:
		if predicate.call(): return true
		await _frames(1)
	return predicate.call()

func _release() -> void:
	for action in InputMap.get_actions():
		if String(action).begins_with("p1_") or String(action).begins_with("p2_"): Input.action_release(action)

func _jp() -> String: return "p%d"%role
func _fp() -> String: return "p%d"%(3-role)
func _tag() -> String: return "Checkpoint Jake P%d: "%role

func _fresh(player_role: int, initial_overlap: bool=false) -> void:
	_release()
	if is_instance_valid(level):
		level.queue_free()
		await _frames(4)
	role=player_role
	level=load("res://level_1.tscn").instantiate()
	finn=level.get_node("Players/Finn")
	jake=level.get_node("Players/Jake")
	finn.player_id=3-role
	jake.player_id=role
	if initial_overlap: finn.position=Vector2(800,245)
	root.add_child(level)
	current_scene=level
	bridge=level.get_node("JakeBridge")
	checkpoint=level.get_node("Checkpoint")
	fall=level.get_node("FallZone")
	activations=0
	starts.clear()
	returns.clear()
	checkpoint.checkpoint_activated.connect(func():activations+=1)
	fall.recovery_started.connect(func():starts.append({"state":bridge.state,"step":bridge.step,"pending":bridge.release_pending}))
	fall.recovery_finished.connect(func(used: bool):returns.append(used))
	if initial_overlap: level.get_node("PermanentBridge").open_gate()
	await _frames(20)

func _capture(name: String) -> void:
	if capture_dir.is_empty() or DisplayServer.get_name()=="headless": return
	DirAccess.make_dir_recursive_absolute(capture_dir)
	await RenderingServer.frame_post_draw
	_check("real capture "+name,root.get_texture().get_image().save_png(capture_dir.path_join(name+".png"))==OK)

func _place(player: Node2D, point: Vector2, wait: int=12) -> void:
	# Controlled fixture, not evidence of a solved puzzle.
	player.global_position=point
	if player is CoopPlayer: (player as CoopPlayer).velocity=Vector2.ZERO
	await _frames(wait)

func _clean_pair() -> bool:
	return finn.visible and jake.visible and finn.animated_sprite.visible and jake.animated_sprite.visible and not finn.movement_locked and not jake.movement_locked and not bridge.bridge_visual.visible and bridge.bridge_body.collision_layer==0 and bridge.state==JakeBridge.State.IDLE and jake.animation_override==&"" and get_nodes_in_group("players").size()==2

func _returned_at(active: bool) -> bool:
	var points: Array[Vector2] = []
	if active: points=checkpoint.get_respawn_positions()
	else: points.assign([Vector2(256,245),Vector2(300,245)])
	return points.size()==2 and absf(finn.position.x-points[0].x)<0.1 and absf(jake.position.x-points[1].x)<0.1 and finn.is_on_floor() and jake.is_on_floor() and not fall._body_rect(finn,finn.global_position).intersects(fall._body_rect(jake,jake.global_position))

func _fall(player: CoopPlayer, active: bool, label: String, duplicate: bool=false) -> void:
	var previous:=fall.recovery_count
	var previous_starts:=starts.size()
	var old_activations:=activations
	# Inject only the fall position, below all bridge support. Recovery is real Area2D logic.
	player.position=Vector2(520,540)
	player.velocity=Vector2.ZERO
	if duplicate:
		var partner:=jake if player==finn else finn
		partner.position=Vector2(560,540)
		partner.velocity=Vector2.ZERO
	var recovered:=await _until(func():return fall.recovery_count>previous,90)
	_release()
	await _frames(20)
	if not _returned_at(active): print("Return diagnostic ",label,": Finn=",finn.position," Jake=",jake.position," active=",checkpoint.activated)
	_check(_tag()+label+" safe distinct return",recovered and _returned_at(active))
	_check(_tag()+label+" exactly one recovery/no new activation",fall.recovery_count==previous+1 and starts.size()==previous_starts+1 and activations==old_activations and returns.back()==active)
	_check(_tag()+label+" sprites, controls and bridge restored",_clean_pair())

func _walk(player: CoopPlayer, prefix: String, target: float, limit: int=480) -> bool:
	Input.action_press(prefix+"_right")
	var before_falls:=fall.recovery_count
	var jumping:=false
	for frame in limit:
		if jumping:
			Input.action_release(prefix+"_jump")
			jumping=false
		if player.position.x>=target: break
		var log: PushBlock=level.get_node("TrunkPuzzle/Log")
		# Use ordinary jumps to leave the already solved log in place. This is
		# test driving, not a new game control or automatic player behaviour.
		if player.is_on_floor() and target>log.global_position.x+50 and log.global_position.x-player.position.x>10 and log.global_position.x-player.position.x<62:
			Input.action_press(prefix+"_jump")
			jumping=true
		await _frames(1)
	var reached:=player.position.x>=target and fall.recovery_count==before_falls
	Input.action_release(prefix+"_right")
	Input.action_release(prefix+"_jump")
	await _frames(12)
	return reached

func _cross_permanent(player: CoopPlayer, prefix: String, target: float) -> bool:
	var ok:=await _walk(player,prefix,380)
	Input.action_press(prefix+"_jump")
	Input.action_press(prefix+"_right")
	await _frames(1)
	Input.action_release(prefix+"_jump")
	var crossed:=await _until(func():return player.position.x>=target,300)
	Input.action_release(prefix+"_right")
	await _frames(12)
	return ok and crossed and player.is_on_floor() and player.position.y<300

func _bridge_cross() -> bool:
	# Actual input from spawn: Jake walks; Finn jumps onto the completed drawing.
	Input.action_press(_jp()+"_ability")
	Input.action_press(_jp()+"_right")
	var approached:=await _until(func():return bridge.state!=JakeBridge.State.IDLE)
	Input.action_release(_jp()+"_right")
	var held:=await _until(func():return bridge.state==JakeBridge.State.HOLDING)
	var walked:=await _walk(finn,_fp(),380)
	Input.action_press(_fp()+"_right")
	Input.action_press(_fp()+"_jump")
	await _frames(1)
	Input.action_release(_fp()+"_jump")
	var crossed:=await _until(func():return finn.position.x>=652)
	Input.action_release(_fp()+"_right")
	await _frames(12)
	return approached and held and walked and crossed and finn.is_on_floor() and fall.recovery_count==0

func _progress_route(player_role: int) -> void:
	await _fresh(player_role)
	_check(_tag()+"inactive checkpoint exports no destinations",not checkpoint.activated and checkpoint.get_respawn_positions().is_empty())
	# Walk into the original gap with no bridge: no teleport is used to cause this fall.
	Input.action_press(_fp()+"_right")
	await _until(func():return finn.position.y>370)
	Input.action_release(_fp()+"_right")
	var returned:=await _until(func():return fall.recovery_count==1)
	await _frames(20)
	_check(_tag()+"natural fall before puzzle returns to start, checkpoint stays inactive",returned and _returned_at(false) and not checkpoint.activated and activations==0 and _clean_pair())
	await _capture("p%d-before-checkpoint-return"%role)
	# Fresh attempt: touching the flag before opening the permanent passage is rejected.
	await _fresh(player_role)
	_check(_tag()+"real bridge crossing without recovery",await _bridge_cross())
	await _walk(finn,_fp(),800)
	_check(_tag()+"flag reachable without lever but cannot activate",not checkpoint.activated and level.get_node("PermanentBridge").collision_layer==0 and fall.recovery_count==0)
	await _capture("p%d-flag-rejected-before-lever"%role)
	# Return by controls to the lever; no fixture placement is counted as solving it.
	Input.action_press(_fp()+"_left")
	# The existing terrain seam near x=800 has a small step when approached
	# from the right. Use the existing jump, without changing terrain/physics.
	Input.action_press(_fp()+"_jump")
	await _frames(1)
	Input.action_release(_fp()+"_jump")
	await _until(func():return finn.position.x<=670)
	Input.action_release(_fp()+"_left")
	await _frames(12)
	print("Lever approach: Finn=",finn.position," overlaps=",level.get_node("Lever").overlaps_body(finn)," range=",level.get_node("Lever")._players_in_range.size())
	await process_frame
	Input.action_press(_fp()+"_interact")
	await process_frame
	if Input.is_action_just_pressed(_fp()+"_interact"): level.get_node("Lever")._process(1.0/60.0)
	await _frames(3)
	Input.action_release(_fp()+"_interact")
	_check(_tag()+"Finn legitimately opens permanent passage",level.get_node("Lever")._is_activated and level.get_node("PermanentBridge").collision_layer==1 and not checkpoint.activated)
	Input.action_release(_jp()+"_ability")
	await _until(func():return bridge.state==JakeBridge.State.IDLE)
	await _fall(finn,false,"fall after lever, before checkpoint")
	_check(_tag()+"first puzzle progress survives pre-checkpoint fall",level.get_node("Lever")._is_activated and level.get_node("PermanentBridge").collision_layer==1)
	_check(_tag()+"Finn crosses preserved passage physically",await _cross_permanent(finn,_fp(),725))
	_check(_tag()+"Jake crosses preserved passage physically",await _cross_permanent(jake,_jp(),700))
	await _walk(finn,_fp(),800)
	_check(_tag()+"one legitimate entrant activates after passage, partner outside",checkpoint.activated and activations==1 and not checkpoint.overlaps_body(jake) and jake.position.x<750)
	await _capture("p%d-legitimate-activation"%role)
	await _fall(finn,true,"fall after activation")
	await _capture("p%d-active-checkpoint-return"%role)
	await _fall(jake,true,"near simultaneous falls",true)
	# A second fall on the following physics tick must still share the same recovery.
	var count:=fall.recovery_count
	finn.position=Vector2(520,540)
	await physics_frame
	jake.position=Vector2(560,540)
	await _until(func():return fall.recovery_count>count)
	await _frames(20)
	_check(_tag()+"staggered fall signals produce one recovery",fall.recovery_count==count+1 and _returned_at(true) and _clean_pair())
	# Keep an ordinary, unfinished but usable object where the player left it.
	var log: PushBlock=level.get_node("TrunkPuzzle/Log")
	await _place(log,Vector2(970,270))
	var log_position:=log.position
	await _fall(finn,true,"unfinished usable log")
	_check(_tag()+"usable unsolved log is not unnecessarily reset",log.position.distance_to(log_position)<0.1)
	# Controlled malformed-object cases test repair, without counting as puzzle solves.
	await _place(log,Vector2(520,320))
	await _fall(finn,true,"unsupported unsolved log")
	_check(_tag()+"unsupported unsolved log restored via existing reset",log.global_position.distance_to(Vector2(930,270))<0.1 and not level.get_node("TrunkPuzzle/Gate").is_open)
	await _place(log,Vector2(824,270))
	await _fall(finn,true,"spawn-obstructing unsolved log")
	_check(_tag()+"unsolved log obstructing markers restored",log.global_position.distance_to(Vector2(930,270))<0.1)
	# Physically solve the trunk puzzle from the checkpoint side.
	await _walk(finn,_fp(),889)
	Input.action_press(_fp()+"_right")
	Input.action_press(_fp()+"_ability")
	var pushed:=await _until(func():return level.get_node("TrunkPuzzle/Gate").is_open,180)
	Input.action_release(_fp()+"_right")
	Input.action_release(_fp()+"_ability")
	await _frames(12)
	log_position=log.position
	_check(_tag()+"trunk puzzle solved by actual pushing",pushed and log.global_position.x>1000)
	await _fall(finn,true,"solved trunk puzzle")
	_check(_tag()+"solved trunk gate and object position preserved",level.get_node("TrunkPuzzle/Gate").is_open and log.position.distance_to(log_position)<0.1)
	var coop: TwoPlayerPuzzle=level.get_node("TwoPlayerPuzzle")
	var first:=finn if finn.player_id==1 else jake
	var second:=jake if jake.player_id==2 else finn
	var first_arrived:=await _walk(first,"p1",coop.player_one_plate.global_position.x-10)
	var second_arrived:=await _walk(second,"p2",coop.player_two_plate.global_position.x-10)
	await _frames(8)
	if not coop.solved: print("Plate route: first=",first.position," second=",second.position," log=",log.global_position," plates=",coop.player_one_plate.is_active(),",",coop.player_two_plate.is_active())
	_check(_tag()+"two-plate puzzle solved by walking assigned controls",first_arrived and second_arrived and coop.solved and coop.gate_to_open.is_open)
	await _fall(jake,true,"two puzzles completed")
	_check(_tag()+"both completed gates and permanent passage preserved",coop.solved and coop.gate_to_open.is_open and level.get_node("TrunkPuzzle/Gate").is_open and level.get_node("PermanentBridge").collision_layer==1)
	# Walk both forward so shared-distance rules remain respected.
	await _walk(finn,_fp(),1370)
	await _walk(jake,_jp(),1560)
	await _walk(finn,_fp(),1950)
	var exit: CooperativeExit=level.get_node("CooperativeExit")
	_check(_tag()+"crystal collected by movement, exit not completed",exit._crystal_collected and not exit._completed)
	await _frames(80) # Allow the crystal's existing SFX/queue_free lifecycle.
	await _fall(finn,true,"collected crystal")
	var remaining_crystal:=level.get_node_or_null("FriendshipCrystal") as FriendshipCrystal
	# Audio completion is driven by the audio clock, not accelerated physics.
	# Either the collected, hidden node or its completed queue_free is valid.
	var crystal_preserved: bool=remaining_crystal==null or (remaining_crystal.is_collected and not remaining_crystal.get_node("Sprite2D").visible and remaining_crystal.get_node("CollisionShape2D").disabled)
	_check(_tag()+"crystal/HUD/exit collection state persist after recovery",exit._crystal_collected and crystal_preserved and level.get_node("HUD/CrystalStatus").text=="Cristal da Amizade recuperado!" and not exit._completed)
	await _capture("p%d-collected-crystal-return"%role)
	await _walk(finn,_fp(),1370)
	await _walk(jake,_jp(),1560)
	await _walk(finn,_fp(),1900)
	await _walk(jake,_jp(),2110)
	_check(_tag()+"recovery does not bypass joint exit",not exit._completed)
	await _walk(finn,_fp(),2110)
	_check(_tag()+"joint exit still completes by physical arrival",exit._completed and exit.completion_label.visible)

func _bridge_recovery(player_role: int, phase: String, active: bool) -> void:
	await _fresh(player_role)
	await _place(jake,Vector2(444,245))
	if phase!="normal":
		Input.action_press(_jp()+"_ability")
		await _frames(2)
		if phase!="source":
			await _until(func():return bridge.step==JakeBridge.Step.GROW and bridge.bridge_visual.progress>0.3)
			if phase!="growth": await _until(func():return bridge.state==JakeBridge.State.HOLDING)
	if active:
		# Fixture for an already conquered checkpoint, not a claim of puzzle progression.
		level.get_node("PermanentBridge").open_gate()
		await _place(finn,Vector2(800,245),4)
		_check(_tag()+"active fixture for "+phase,checkpoint.activated)
	if phase=="pending":
		await _place(finn,Vector2(528,239))
		Input.action_release(_jp()+"_ability")
		await _frames(4)
	elif phase=="shrink" or phase=="reverse":
		await _place(finn,Vector2(320,245))
		Input.action_release(_jp()+"_ability")
		await _until(func():return bridge.step==JakeBridge.Step.SHRINK)
		if phase=="reverse": await _until(func():return bridge.step==JakeBridge.Step.SOURCE_RETRACT)
	var expected_step:=bridge.step
	var expected_state:=bridge.state
	var expected_pending:=bridge.release_pending
	var falling:=jake if phase=="pending" else finn
	await _fall(falling,active,"bridge "+phase+" active="+str(active))
	var observed: Dictionary=starts.back()
	_check(_tag()+"fall observed during requested bridge phase "+phase,observed["step"]==expected_step and observed["state"]==expected_state and (phase!="pending" or expected_pending))
	if active:
		_check(_tag()+"permanent bridge survives "+phase,level.get_node("PermanentBridge").collision_layer==1)
	# Both identities receive their own controls again after recovery.
	var old_finn:=finn.position.x
	var old_jake:=jake.position.x
	Input.action_press(_fp()+"_left")
	Input.action_press(_jp()+"_left")
	await _frames(6)
	_release()
	_check(_tag()+"both control slots restored after "+phase,finn.position.x<old_finn-3 and jake.position.x<old_jake-3)

func _startup_case(player_role: int) -> void:
	await _fresh(player_role,true)
	_check(_tag()+"initial overlap with opened passage does not activate",not checkpoint.activated and activations==0)
	await _place(finn,Vector2(730,245))
	await _walk(finn,_fp(),800)
	_check(_tag()+"fresh entry after startup can activate",checkpoint.activated and activations==1)
	var count:=activations
	await _place(jake,Vector2(800,245))
	_check(_tag()+"checkpoint activation is latched once",activations==count)

func _run() -> void:
	root.size=Vector2i(1152,648)
	for player_role in [2,1]:
		await _progress_route(player_role)
		await _startup_case(player_role)
		for phase in ["normal","source","growth","hold","pending","shrink","reverse"]:
			await _bridge_recovery(player_role,phase,false)
		for phase in ["hold","pending","shrink","reverse"]:
			await _bridge_recovery(player_role,phase,true)
	_release()
	if is_instance_valid(level): level.queue_free()
	await _frames(4)
	await create_timer(1.0).timeout
	level=null
	finn=null
	jake=null
	bridge=null
	checkpoint=null
	fall=null
	if not report_path.is_empty():
		FileAccess.open(report_path,FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"headless":DisplayServer.get_name()=="headless","fixtures_are_progression_evidence":false},"\t"))
	print("Checkpoint checks: ",checks.size()," | failures: ",failures)
	quit(0 if failures==0 else 1)
