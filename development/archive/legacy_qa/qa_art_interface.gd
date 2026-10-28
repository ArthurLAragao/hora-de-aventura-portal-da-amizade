extends "res://tests/journey_driver.gd"
## Button-handler fixtures are separate from the normal route ending evidence.
func key(target: Node,code: Key) -> void:
	var event:=InputEventKey.new();event.keycode=code;event.pressed=true
	target._unhandled_key_input(event);await frames(4)
func run() -> void:
	root.size=viewport_size
	await fresh("res://level_1.tscn",1,"finn_player_id")
	var presentation=level.get_node("QualityPresentation")
	check("help starts closed",not presentation.help.visible)
	await key(presentation,KEY_F1)
	check("optional help opens without pausing or locking either player",presentation.help.visible and not paused and not level.finn.movement_locked and not level.jake.movement_locked)
	await capture("art-help-open")
	await key(presentation,KEY_ESCAPE)
	check("Escape closes help",not presentation.help.visible)
	await frames(200)
	check("role identification is brief, not a permanent tutorial",not level.hud.get_node("Hints").visible)
	for button_name in ["Phases","Menu"]:
		await fresh("res://level_6.tscn",1,"primary_player_id")
		var ending:=CanvasLayer.new();ending.set_script(load("res://scripts/ui/friendship_ending.gd"));level.add_child(ending)
		await frames(3)
		stop_test_audio(level)
		ending.get_node(button_name).pressed.emit()
		await frames(15)
		check("ending button "+button_name+" reaches its actual scene",current_scene.scene_file_path==("res://phase_select.tscn" if button_name=="Phases" else "res://Assets/04_Interface/Godot/main_menu.tscn"))
		current_scene.queue_free()
		await frames(4)
		level=null
	await finish("Art interface handlers")
