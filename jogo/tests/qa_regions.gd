extends "res://tests/journey_driver.gd"

func run() -> void:
	for size in [Vector2i(1152,648),Vector2i(1280,720)]:
		root.size=size
		for number in [2,3,4,6]:
			release()
			if is_instance_valid(level):
				stop_test_audio(level);level.queue_free();await frames(4)
			change_scene_to_file("res://phase_select.tscn")
			await frames(10)
			var selector:=current_scene
			check("selector keeps only phase 5 disabled",selector.get_node("Design/Phase5").disabled and not selector.get_node("Design/Phase%d"%number).disabled)
			if number==2:await capture_selector("selector-%d"%size.x)
			selector.get_node("Design/Phase%d"%number).pressed.emit()
			await frames(28);level=current_scene
			check("selector opens phase %d at %s"%[number,size],level.scene_file_path=="res://level_%d.tscn"%number)
			if number in [2,3,4]:
				check("phase %d has one regional art layer"%number,level.get_node_or_null("RegionalScenery")!=null)
				var physics_count:=count_physics(level.get_node("RegionalScenery"))
				check("phase %d scenery does not introduce colliders"%number,physics_count==0)
				await capture("region%d-%d"%[number,size.x])
				if number!=2:
					var hud=level.get_node("HUD")
					hud.help_panel.show();await frames(3)
					check("phase %d optional help fits viewport"%number,hud.help_panel.get_rect().end.x<=size.x and hud.help_panel.get_rect().end.y<=size.y)
					await capture("region%d-help-%d"%[number,size.x]);hud.help_panel.hide()
				else:check("phase 2 still identifies unfinished completion",level.get_node("FinalHint").text.contains("pendentes"))
	await finish("Regional presentation")

func count_physics(node: Node) -> int:
	var total:=1 if node is CollisionObject2D else 0
	for child in node.get_children():total+=count_physics(child)
	return total

func capture_selector(name: String) -> void:
	if capture_dir=="":return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(capture_dir.path_join(name+".png"))
