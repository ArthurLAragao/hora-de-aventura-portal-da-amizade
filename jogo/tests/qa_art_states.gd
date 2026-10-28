extends "res://tests/journey_driver.gd"
## Repositioning / state setup in this suite is only for image/state inspection.
func place(actor: Node2D,at: Vector2) -> void:
	actor.position=at
	if actor is CoopPlayer: actor.velocity=Vector2.ZERO
	await frames(12)
func visible_art(plate: Node2D,label: String) -> void:
	check(label+": mechanism is visible before/during/after activation",plate.is_visible_in_tree())
	if plate.has_method("visual_state"):
		check(label+": plate is above terrain and below characters",plate.z_index==1)
		await RenderingServer.frame_post_draw
		var point: Vector2=plate.get_global_transform_with_canvas().origin
		var image:=root.get_texture().get_image()
		var matched:=0
		for y in range(maxi(0,int(point.y)-29),mini(image.get_height(),int(point.y)+3)):
			for x in range(maxi(0,int(point.x)-48),mini(image.get_width(),int(point.x)+48)):
				var c:=image.get_pixel(x,y)
				if c.is_equal_approx(Color("ffe79b")) or c.is_equal_approx(Color("dba754")) or c.is_equal_approx(Color("a5ebc1")) or c.is_equal_approx(Color("68838c")): matched+=1
		check(label+": actual rendered emblem/rim pixels are present",matched>12)
func check_plants() -> void:
	for sprite in level.get_node("ArtDirection").get_children():
		if not sprite is Sprite2D or not sprite.has_meta("support_y"):continue
		var used=sprite.texture.get_image().get_used_rect()
		var bottom: float=sprite.global_position.y+(used.end.y-sprite.texture.get_height()*0.5)*sprite.global_scale.y
		check(sprite.name+": opaque footprint meets its terrain baseline",absf(bottom-sprite.get_meta("support_y"))<0.2)
func run() -> void:
	root.size=viewport_size
	await fresh("res://level_1.tscn",1,"finn_player_id")
	await check_plants()
	await visible_art(level.tutorial_plate,"F1 initial")
	await capture("art-f1-plate-before")
	await place(level.tutorial_log,Vector2(416,level.LEFT_FLOOR-15))
	await visible_art(level.tutorial_plate,"F1 socket complete")
	await capture("art-f1-plate-complete")
	await place(level.finn,Vector2(1800,level.FLOOR-32.5))
	await place(level.jake,Vector2(1790,level.FLOOR-112.5))
	await frames(40)
	await visible_art(level.top_plate,"F1 upper available")
	await visible_art(level.log_plate,"F1 lower available")
	await capture("art-f1-pair-before")
	await place(level.jake,Vector2(1856,level.FLOOR-112.5))
	await visible_art(level.top_plate,"F1 upper pressed")
	await capture("art-f1-pair-pressed")
	await place(level.log,Vector2(1848,level.FLOOR-15))
	await capture("art-f1-pair-complete")
	await fresh("res://level_6.tscn",1,"primary_player_id")
	await place(level.pair[0],Vector2(400,level.LEFT_FLOOR-32.5))
	await place(level.pair[1],Vector2(448,level.LEFT_FLOOR-32.5))
	await frames(35)
	await check_plants()
	await visible_art(level.reunion_a[0],"F6 reunion before repair")
	await capture("art-f6-reunion-inactive")
	await place(level.log,Vector2(736,level.FLOOR-15))
	await frames(15)
	await visible_art(level.reunion_a[0],"F6 reunion available")
	await capture("art-f6-reunion-available")
	level.set_physics_process(false) # Hold the visual pose for a screenshot, not route evidence.
	await place(level.pair[0],Vector2(640,level.FLOOR-32.5))
	await place(level.pair[1],Vector2(784,level.FLOOR-32.5))
	await frames(35)
	await visible_art(level.reunion_a[0],"F6 reunion pressed left")
	await visible_art(level.reunion_a[1],"F6 reunion pressed right")
	await capture("art-f6-reunion-pressed")
	level.set_physics_process(true)
	await until(func():return level.stage==1 and not level._transitioning)
	await visible_art(level.reunion_b[0],"F6 new pair")
	await capture("art-f6-new-pair")
	level._repair(1);level._advance_pair(2)
	await until(func():return level.stage==2 and not level._transitioning)
	await place(level.pair[0],Vector2(512,level.LEFT_FLOOR-43.85))
	await place(level.pair[1],Vector2(784,level.FLOOR-32.5))
	await visible_art(level.confirmation[0],"F6 final before signal")
	await capture("art-f6-confirm-inactive")
	level._repair(2)
	await frames(15)
	await visible_art(level.confirmation[0],"F6 final confirmed")
	await capture("art-f6-confirm-complete")
	level.recover_pair();await until(func():return not level._recovering)
	await frames(20)
	await visible_art(level.confirmation[0],"F6 confirmation after recovery")
	await capture("art-f6-confirm-recovery")
	var event:=InputEventKey.new();event.keycode=KEY_F2;event.pressed=true
	level._unhandled_key_input(event);await frames(30);level=current_scene
	await visible_art(level.reunion_a[0],"F6 restart")
	await capture("art-f6-restart")
	await finish("Art mechanism state inspection")
