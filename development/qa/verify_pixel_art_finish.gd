extends "res://tests/journey_driver.gd"
## Prepared visual fixtures, separate from the input-driven full-route tests.
func run() -> void:
	root.size=viewport_size
	for number in [3,4]:
		await open(number)
		for gate in level.find_children("*","StaticBody2D",true,false):
			if not gate is CoopGate:continue
			var art=gate.get_node("RegionalFinish")
			check("native leaf matches existing gate support rectangle",art.leaf_sprite.texture.get_size()==art.box.size and art.leaf_sprite.scale==Vector2.ONE)
			var frame: Image=art.frame_sprite.texture.get_image()
			var clear:=true
			for y in range(12,12+int(art.box.size.y)):
				for x in range(8,56):
					if frame.get_pixel(x,y).a>0:clear=false
			check("frame opening is genuinely transparent",clear)
			check("door has binary alpha and limited native palette",pixel_palette(art.leaf_sprite.texture.get_image(),40) and pixel_palette(frame,40))
			gate.open_gate();await frames(2)
			check("open gate retains frame while removing leaf and collider",art.frame_sprite.visible and not art.leaf_sprite.visible and gate.get_node("CollisionShape2D").disabled)
		for body in level.get_node("RegionalLayout").get_children():
			if not body is StaticBody2D:continue
			var total:=0.0
			for child in body.get_children():
				if child is Sprite2D:total+=child.region_rect.size.x
			var collision:=body.get_child(0) as CollisionShape2D
			check("platform art ends at the physical support",is_equal_approx(total,collision.shape.size.x))
		if number==3:
			level.marceline.position=Vector2(1300,360);level.bmo.position=Vector2(1320,360)
			await frames(25);await capture("pixel-cave-islands-%d"%viewport_size.x)
	await open(4)
	level.finn.position=Vector2(1260,350);level.bmo.position=Vector2(1320,350)
	await frames(25)
	check("circuit starts with clearly vertical disconnected conductors",level.connections.turns==[1,1] and is_equal_approx(level.connections.rotors[0].rotation,PI*0.5))
	check("receiver begins unpowered",not level.connections.locked and not level.connections.panel_material.get_shader_parameter("powered"))
	await capture("pixel-circuit-disconnected-%d"%viewport_size.x)
	await circuit_detail("disconnected")
	level.finn.position=Vector2(1432,350);await frames(8)
	await tap(level.finn,"interact")
	check("original contextual input rotates the first conductor",level.connections.turns[0]==0)
	await walk(level.finn,1520);await tap(level.finn,"interact")
	check("both physical conductor paths align",level.connections.solved() and is_zero_approx(level.connections.rotors[1].rotation))
	await walk(level.finn,1260)
	await capture("pixel-circuit-aligned-%d"%viewport_size.x)
	await tap(level.bmo,"interact");await frames(100)
	check("existing BMO action powers receiver and opens original gate",level.energy_terminal.energized and level.energy_gate.is_open and level.connections.locked and level.connections.panel_material.get_shader_parameter("powered"))
	await capture("pixel-circuit-powered-%d"%viewport_size.x)
	await circuit_detail("powered")
	await open(4)
	check("scene restart restores circuit and door visuals",not level.connections.locked and not level.energy_gate.is_open and level.connections.turns==[1,1])
	await finish("Native pixel art and live circuit presentation")

func open(number: int) -> void:
	release()
	if is_instance_valid(level):stop_test_audio(level);level.queue_free();await frames(4)
	level=load("res://level_%d.tscn"%number).instantiate();root.add_child(level);current_scene=level
	await frames(30)

func pixel_palette(img: Image,limit: int) -> bool:
	var colors: Dictionary={}
	for y in img.get_height():
		for x in img.get_width():
			var c:=img.get_pixel(x,y)
			if c.a!=0 and c.a!=1:return false
			if c.a==1:colors[c.to_rgba32()]=true
	return colors.size()<=limit

func circuit_detail(state: String) -> void:
	if DisplayServer.get_name()=="headless" or capture_dir=="":return
	await RenderingServer.frame_post_draw
	var canvas:=root.get_final_transform()*root.get_canvas_transform()
	var start:=Vector2i(canvas*Vector2(1328,308))
	var end:=Vector2i(canvas*Vector2(1584,388))
	var detail:=root.get_texture().get_image().get_region(Rect2i(start,end-start))
	detail.resize(detail.get_width()*4,detail.get_height()*4,Image.INTERPOLATE_NEAREST)
	detail.save_png(capture_dir.path_join("circuit-detail-"+state+".png"))
