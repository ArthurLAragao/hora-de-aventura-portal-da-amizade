extends SceneTree
## Local bridge fixtures, distinct from verify_cake's complete real movement route.
var room: Node2D
var cake: CoopPlayer
var partner: CoopPlayer
var anchor: Area2D
var failures:=0
var checks: Array[Dictionary]=[]
var role:=1
var report_path:=""
func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--report="): report_path=arg.trim_prefix("--report=")
	call_deferred("run")
func frames(n: int) -> void:
	for i in n:
		await physics_frame
		await process_frame
func release() -> void:
	for a in InputMap.get_actions():
		if String(a).begins_with("p1_") or String(a).begins_with("p2_"): Input.action_release(a)
func check(label: String,ok: bool) -> void:
	checks.append({"check":"P%d: %s"%[role,label],"passed":ok})
	print(("PASS " if ok else "FAIL ")+"P%d: "%role+label)
	if not ok: failures+=1
func fresh(slot: int,offset: float=0) -> void:
	release()
	if is_instance_valid(room):
		room.queue_free()
		await frames(4)
	role=slot
	room=load("res://tests/cake_test.tscn").instantiate()
	room.cake_player_id=slot
	root.add_child(room)
	current_scene=room
	cake=room.cake
	partner=room.fionna
	anchor=room.anchor
	await frames(12)
	# Explicit local fixtures, never described as full-level traversal.
	cake.position=Vector2(912+offset,340)
	partner.position=Vector2(875,340)
	await frames(30)
func hold() -> void:
	Input.action_press("p%d_ability"%role)
	await frames(110)
func walk_partner(target: float) -> void:
	Input.action_press("p%d_right"%(3-role))
	for i in 150:
		if partner.position.x>=target: break
		await frames(1)
	Input.action_release("p%d_right"%(3-role))
	await frames(15)
func jump_partner(target: float) -> void:
	Input.action_press("p%d_jump"%(3-role))
	Input.action_press("p%d_right"%(3-role))
	await frames(2)
	Input.action_release("p%d_jump"%(3-role))
	for i in 100:
		if partner.position.x>=target: break
		await frames(1)
	Input.action_release("p%d_right"%(3-role))
	await frames(45)
func run() -> void:
	for slot in [1,2]:
		for offset in [-8.0,8.0]:
			await fresh(slot,offset)
			await hold()
			await jump_partner(940)
			check("accepted band endpoint %s has physical entry support"%offset,partner.is_on_floor() and anchor.get_dependents().has(partner))
			anchor.cancel_immediately()
			await frames(5)
			check("cancel while occupied defers loss of support",anchor._support_active and anchor.release_pending)
			Input.action_release("p%d_ability"%role)
			await walk_partner(977)
			await jump_partner(1040)
			await frames(100)
			check("endpoint exit is physical, safe, no recovery",partner.is_on_floor() and partner.position.x>1030 and room.recovery_count==0 and not cake.movement_locked and anchor.support.collision_layer==0)
		for phase in ["source","growth","hold","pending","retract"]:
			await fresh(slot)
			Input.action_press("p%d_ability"%role)
			await frames(3 if phase=="source" else (40 if phase=="growth" else 110))
			if phase=="pending":
				await jump_partner(940)
				Input.action_release("p%d_ability"%role)
				await frames(5)
			if phase=="retract":
				Input.action_release("p%d_ability"%role)
				await frames(10)
			room.recover_pair()
			release()
			await frames(20)
			check("pair recovery cleans all state during "+phase,anchor.state==anchor.State.IDLE and anchor.support.collision_layer==0 and cake.animated_sprite.visible and not cake.movement_locked and not partner.movement_locked and cake.position.x==256 and partner.position.x==160)
		await fresh(slot)
		Input.action_press("p%d_ability"%role)
		await frames(45)
		check("growth still has no collision",not anchor._support_active)
		Input.action_release("p%d_ability"%role)
		await frames(110)
		check("mid-growth cancellation leaves no support or lock",not cake.movement_locked and cake.animated_sprite.visible and anchor.support.collision_layer==0)
		await hold()
		var key:=InputEventKey.new()
		key.keycode=KEY_F2
		key.pressed=true
		room._unhandled_key_input(key)
		await frames(20)
		room=current_scene
		release()
		check("F2 during full support leaves no abandoned bridge",room.anchor.support.collision_layer==0 and room.cake.animated_sprite.visible and not room.cake.movement_locked)
	room.queue_free()
	await frames(3)
	if not report_path.is_empty(): FileAccess.open(report_path,FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"local_fixtures_only":true},"\t"))
	print("Cake safety checks: ",checks.size()," failures: ",failures)
	quit(0 if failures==0 else 1)
