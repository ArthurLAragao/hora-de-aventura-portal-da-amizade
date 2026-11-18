extends "res://tests/journey_driver.gd"
## All placements in this file are isolated risk fixtures, not normal-route evidence.
var owner: CoopPlayer
var partner: CoopPlayer
var anchor: Node2D
var is_cake:=false

func fixture(cake_mode: bool,slot: int,offset: float=0.0) -> void:
	is_cake=cake_mode
	await fresh("res://tests/cake_test.tscn" if is_cake else "res://tests/jake_test.tscn",slot,"cake_player_id" if is_cake else "jake_player_id")
	owner=level.get_node("Cake" if is_cake else "Jake")
	partner=level.get_node("Fionna" if is_cake else "Finn")
	anchor=level.get_node("Anchor" if is_cake else "JakeBridge")
	var p: Vector2=anchor.offer_position()
	owner.position=p+Vector2(offset,-1)
	partner.position=Vector2(760,350.35) if is_cake else Vector2(320,245)
	owner.velocity=Vector2.ZERO
	partner.velocity=Vector2.ZERO
	await frames(18)

func active() -> bool:
	return anchor._support_active if is_cake else anchor._bridge_active

func restored() -> bool:
	return not owner.movement_locked and owner.animated_sprite.visible and owner.collision_mask==1 and not active() and anchor.state==0

func esc() -> void:
	var event:=InputEventKey.new()
	event.keycode=KEY_ESCAPE
	event.pressed=true
	anchor._unhandled_key_input(event)
	await frames(3)

func risk_cases(cake_mode: bool,slot: int) -> void:
	var name: String="Cake" if cake_mode else "Jake"
	# Positions on the same, actual bank. Beyond the bank is tested as invalid below.
	for offset in ([-32.0,-16.0,0.0,10.0] if cake_mode else [-64.0,-36.0,0.0,16.0]):
		await fixture(cake_mode,slot,offset)
		var start:=owner.position
		check(name+": wide safe request at offset "+str(offset),anchor.can_request(owner))
		Input.action_press(action(owner,"ability"))
		await frames(5)
		check(name+": early motion is a walk, not a teleport",absf(owner.position.x-start.x)<=9 and not active())
		if absf(offset)>15: await capture(name.to_lower()+"-approach-"+str(int(offset)))
		var formed:=await until(func():return active(),240)
		check(name+": fixed formation reached with original mask restored",formed and absf(owner.position.x-anchor.offer_position().x)<0.6 and owner.collision_mask==1 and not owner.animated_sprite.visible)
		await capture(name.to_lower()+"-formed-"+str(int(offset)))
		Input.action_release(action(owner,"ability"))
		await until(func():return restored(),240)
		check(name+": release restores sprite and controls",restored())
	await fixture(cake_mode,slot,-24)
	Input.action_press(action(owner,"ability"))
	await frames(4)
	Input.action_release(action(owner,"ability"))
	await frames(6)
	check(name+": quick release cancels approach without support",restored())
	for i in 4:
		await tap(owner,"ability",1)
	await frames(8)
	check(name+": repeated taps do not retain a lock",restored())
	await fixture(cake_mode,slot,-24)
	Input.action_press(action(owner,"ability"))
	await frames(4)
	await esc()
	await frames(15)
	check(name+": Esc cancels even while ability remains held",restored())
	Input.action_release(action(owner,"ability"))
	await fixture(cake_mode,slot,-32)
	Input.action_press(action(owner,"ability"))
	await frames(5)
	Input.action_press(action(owner,"left"))
	await frames(4)
	release()
	await frames(3)
	check(name+": opposite direction cancels the assisted walk",restored())
	await fixture(cake_mode,slot,-32)
	Input.action_press(action(owner,"ability"))
	await frames(4)
	await tap(owner,"jump")
	check(name+": jump cancels approach and retains the jump request",not owner.movement_locked and not active() and owner.velocity.y<0)
	release()
	await fixture(cake_mode,slot,-28)
	partner.position=owner.position+Vector2(28,0)
	await frames(8)
	check(name+": occupied trajectory refuses rather than crossing partner",not anchor.can_request(owner))
	await tap(owner,"ability")
	check(name+": refusal leaves controls available",not owner.movement_locked and not active())
	await fixture(cake_mode,slot,-24)
	owner.position.y-=36
	owner.velocity=Vector2.ZERO
	await frames(1)
	check(name+": airborne request refused",not anchor.can_request(owner))
	await tap(owner,"ability")
	check(name+": no midair bridge or lock",not active() and not owner.movement_locked)
	await fixture(cake_mode,slot,-24)
	# A visible wall is a fixture obstruction, never a gameplay fix.
	var wall=preload("res://scripts/core/journey_build.gd").wall(level,"FixtureWall",owner.position+Vector2(28,0),Vector2(8,64))
	await frames(5)
	check(name+": physical wall rejects assisted path",not anchor.can_request(owner))
	wall.queue_free()
	await frames(4)
	check(name+": removing obstruction restores truthful offer",anchor.can_request(owner))
	await fixture(cake_mode,slot,-24)
	Input.action_press(action(owner,"ability"))
	await frames(5)
	# The partner enters AFTER an initially valid request.
	partner.position=owner.position+Vector2(28,0)
	await frames(10)
	Input.action_release(action(owner,"ability"))
	check(name+": late obstacle cancels rather than crushing or continuing",restored())
	await fixture(cake_mode,slot,0)
	Input.action_press(action(owner,"ability"))
	await until(func():return active(),240)
	var p: Vector2=anchor.offer_position()
	var top_y: float=anchor.support.global_position.y+20 if is_cake else anchor.to_global(anchor.get_support_rect().position).y
	partner.position=Vector2(p.x+52,top_y-32.5)
	partner.velocity=Vector2.ZERO
	await frames(22)
	check(name+": isolated rider really stands on support",partner.is_on_floor() and anchor.get_dependents().has(partner))
	Input.action_release(action(owner,"ability"))
	await frames(10)
	check(name+": standing rider retains support",active())
	await tap(partner,"jump")
	await frames(8)
	check(name+": airborne rider retains support",not partner.is_on_floor() and active())
	if is_cake:
		await until(func():return partner.is_on_floor())
		var crossed:=await walk(partner,1036,180)
		check("Cake: walking across the head has no upward snag or recovery",crossed and partner.position.x>1030 and partner.is_on_floor() and level.recovery_count==0)
		await capture("cake-head-walk")
	# Recovery must restore the ordinary collider/mask even from an approach.
	if is_cake: level.recover_pair()
	else: anchor._finish_retraction()
	release()
	await frames(10)
	check(name+": forced recovery leaves no invisible support",restored())

func adjacent_anchors(slot: int) -> void:
	await fixture(false,slot,-28)
	var other=load("res://jake_bridge.tscn").instantiate()
	other.name="SecondAnchorFixture"
	other.position=anchor.position+Vector2(-48,0)
	level.add_child(other)
	var body=other.get_node("BridgeBody")
	var collision=body.get_node("CollisionShape2D")
	collision.shape=collision.shape.duplicate()
	collision.shape.size.x+=48
	body.position.x+=24 # Same real far bank; not a truncated, invalid bridge.
	await frames(5)
	Input.action_press(action(owner,"ability"))
	await frames(4)
	check("two anchors: exactly the nearest safe anchor claims the input",other.approach.active and not anchor.approach.active)
	await until(func():return other._bridge_active,240)
	check("two anchors: selection stays with the same owner through formation",other._bridge_active and not anchor._bridge_active and absf(owner.position.x-other.offer_position().x)<0.6)
	Input.action_release(action(owner,"ability"))
	await until(func():return other.state==0,240)
	check("two anchors: complete cleanup",not owner.movement_locked and owner.collision_mask==1)

func run() -> void:
	for slot in [1,2]:
		await risk_cases(false,slot)
		await risk_cases(true,slot)
		await adjacent_anchors(slot)
	await finish("QA bridge risks")
