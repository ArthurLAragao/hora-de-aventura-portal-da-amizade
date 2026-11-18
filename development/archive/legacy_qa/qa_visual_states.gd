extends "res://tests/journey_driver.gd"
## Controlled visual states only; normal traversal is verified separately.
var clips_root:=""
func _initialize() -> void:
	super._initialize()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--clips="):clips_root=arg.trim_prefix("--clips=")
func record(folder: String,start: int,count: int) -> void:
	if clips_root=="":return
	var out:=clips_root.path_join(folder)
	DirAccess.make_dir_recursive_absolute(out)
	for i in count:
		await frames(6);OS.delay_msec(80)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(out.path_join("%03d.png"%(start+i)))
func run() -> void:
	root.size=viewport_size
	await fresh("res://level_6.tscn",1,"primary_player_id")
	level.set_physics_process(false)
	await capture("refine-lights-0")
	await record("luzes-estados-controlados",0,10)
	for i in 3:
		level._repair(i)
		await record("luzes-estados-controlados",10+i*12,12)
		check("lamp state matches repair %d"%i,level.portal.light_states()==level.repaired)
		await capture("refine-lights-%d"%(i+1))
	level.recover_pair()
	await until(func():return not level._recovering)
	check("recovery keeps the three acquired lights",level.portal.light_states()==[true,true,true])
	await capture("refine-lights-recovery")
	var event:=InputEventKey.new();event.keycode=KEY_F2;event.pressed=true
	level._unhandled_key_input(event);await frames(30);level=current_scene
	check("full restart switches all three lights off",level.portal.light_states()==[false,false,false])
	await fresh("res://level_1.tscn",1,"finn_player_id")
	await frames(220)
	var art=level.get_node("ArtDirection")
	var shaders:=0
	for child in art.get_children():
		if child is Sprite2D and child.material is ShaderMaterial:
			shaders+=1
			check(child.name+": decorative breeze uses a pinned foot",child.material.get_shader_parameter("foot_y")>0.8 and child.has_meta("support_y"))
	check("breeze is limited to decorative foliage",shaders>0 and level.finn.animated_sprite.material==null and level.jake.animated_sprite.material==null)
	await capture("refine-forest-idle")
	await record("folhagem-fase1",0,64)
	await finish("Refinement controlled visual states")
