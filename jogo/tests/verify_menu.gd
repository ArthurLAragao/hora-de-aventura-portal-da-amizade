extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(label: String, condition: bool) -> void:
	print(("PASS " if condition else "FAIL ") + label)
	if not condition:
		failures += 1

func _run() -> void:
	var menu_scene := load("res://Assets/04_Interface/Godot/main_menu.tscn") as PackedScene
	_check("existing main menu loads", menu_scene != null)
	if menu_scene == null:
		quit(1)
		return
	var menu := menu_scene.instantiate()
	root.add_child(menu)
	current_scene = menu
	await process_frame
	_check("main menu play button exists", menu.has_node("Design/Buttons/play"))
	root.size = Vector2i(1024, 768)
	await process_frame
	await process_frame
	var menu_design: Control = menu.get_node("Design")
	_check("main menu fits a 4:3 window without cropping its design", menu_design.position.x >= 0.0 and menu_design.position.y >= 0.0 and menu_design.position.x + menu_design.size.x * menu_design.scale.x <= menu.size.x + 1.0 and menu_design.position.y + menu_design.size.y * menu_design.scale.y <= menu.size.y + 1.0)
	root.size = Vector2i(1152, 648)
	await process_frame
	await process_frame
	(menu.get_node("Design/Buttons/play") as TextureButton).pressed.emit()
	await process_frame
	await process_frame
	var phase_select := current_scene
	_check("play opens phase selection", phase_select != null and phase_select.name == "PhaseSelect")
	if phase_select == null or phase_select.name != "PhaseSelect":
		quit(1)
		return
	await process_frame
	var first := phase_select.get_node("Design/Phase1") as Button
	_check("phase one is enabled", first != null and not first.disabled)
	_check("phase selector renders each button caption only once", first != null and first.text == "FASE 1   |   JOGAR" and first.get_child_count() == 0)
	var unavailable := 0
	var phase_buttons: Array[Button] = []
	for phase in range(2, 7):
		var button := phase_select.get_node("Design/Phase%d" % phase) as Button
		if button != null:
			phase_buttons.append(button)
		if button != null and button.disabled:
			unavailable += 1
	_check("phases two through six are visibly unavailable", unavailable == 5)
	var cards_do_not_overlap := true
	phase_buttons.append(first)
	for left_index in range(phase_buttons.size()):
		for right_index in range(left_index + 1, phase_buttons.size()):
			if phase_buttons[left_index].get_rect().intersects(phase_buttons[right_index].get_rect()):
				cards_do_not_overlap = false
	_check("phase buttons do not overlap", cards_do_not_overlap)
	root.size = Vector2i(1024, 768)
	await process_frame
	await process_frame
	var design: Control = phase_select.get_node("Design")
	_check("selector fits a 4:3 window without clipping the design", design.position.x >= 0.0 and design.position.y >= 0.0 and design.position.x + design.size.x * design.scale.x <= phase_select.size.x + 1.0 and design.position.y + design.size.y * design.scale.y <= phase_select.size.y + 1.0)
	root.size = Vector2i(1152, 648)
	await process_frame
	await process_frame
	first.pressed.emit()
	await process_frame
	await process_frame
	_check("phase one button opens the playable level", current_scene != null and current_scene.name == "Level1")
	print("Menu check failures: ", failures)
	quit(0 if failures == 0 else 1)
