extends "res://tests/journey_driver.gd"
## Isolated measurement fixtures; do not count these placements as a completed route.
func run() -> void:
	root.size=viewport_size
	for n in [2,3,4]:
		if is_instance_valid(level):stop_test_audio(level);level.queue_free();await frames(4)
		level=load("res://level_%d.tscn"%n).instantiate();root.add_child(level);current_scene=level;await frames(35)
		var sprite: Sprite2D=level.get_node("FriendshipCrystal/Sprite2D")
		check("phase %d uses its distinct crystal asset"%n,sprite.texture.resource_path.ends_with("crystal_"+{2:"green",3:"purple",4:"orange"}[n]+".png"))
		var comp=level.get_node("RegionalScenery/RegionalComposition")
		check("phase %d keeps lanterns on visible suspensions"%n,comp.glow.size()>=2)
		await capture("feedback-%d-start"%n)
		if n==2 and DisplayServer.get_name()!="headless":
			await RenderingServer.frame_post_draw
			var image:=root.get_texture().get_image()
			var a:=Vector2i(root.get_canvas_transform()*Vector2(460,508))
			var b:=Vector2i(root.get_canvas_transform()*Vector2(536,508))
			var c1:=image.get_pixelv(a);var c2:=image.get_pixelv(b)
			check("tunnel renders real texture detail rather than flat tint",absf(c1.r-c2.r)+absf(c1.g-c2.g)+absf(c1.b-c2.b)>0.08)
		if n==3:
			var template:=load("res://Assets/02_Environments/03_musical_cave/tileset.tres") as TileSet
			var original:=template.get_source(0) as TileSetAtlasSource
			check("cave collision correction leaves shared tileset template untouched",is_equal_approx(original.get_tile_data(Vector2i(1,0),0).get_collision_polygon_points(0,0)[0].y,-10))
			for actor in [level.marceline,level.bmo]:
				var feet:=visible_feet(actor)
				check("cave grounded sprite aligns with visible floor: "+actor.name,actor.is_on_floor() and absf(feet-394)<0.2)
			for node in comp.layers["Vegetation"].get_children():
				check("cave vegetation reaches the same surface: "+node.name,is_equal_approx(node.get_meta("support_y"),394.0))
			await walk(level.marceline,320)
			check("walking preserves floor contact within one animation pixel",absf(visible_feet(level.marceline)-394)<1.2)
		if n==4:
			check("carrier docks at bank without overshooting gap",is_equal_approx(level.carrier.start.x+64,576))
			level.get_node("TrunkPuzzle/Log").global_position=Vector2(512,374)
			await frames(3);level.carrier.start_route();await frames(180)
			check("carrier spans precisely the full opening at arrival",level.carrier.arrived and is_equal_approx(level.carrier.position.x-64,576) and is_equal_approx(level.carrier.position.x+64,704))
			for x in [576.1,640.0,703.9]:
				var query:=PhysicsRayQueryParameters2D.create(Vector2(x,384),Vector2(x,400),1)
				var hit:=level.get_world_2d().direct_space_state.intersect_ray(query)
				check("bridge supports entry/center/exit at x=%s"%x,not hit.is_empty() and absf(hit.position.y-388)<0.1)
			await capture("feedback-4-covered-gap")
	await finish("Feedback art alignment and coverage fixtures")
func visible_feet(actor: CoopPlayer) -> float:
	var sprite:=actor.animated_sprite
	var tex:=sprite.sprite_frames.get_frame_texture(sprite.animation,sprite.frame)
	var used:=tex.get_image().get_used_rect()
	return (sprite.global_transform*Vector2(0,used.end.y-tex.get_height()*0.5+sprite.offset.y)).y
