extends Control
## Responsive selector for the phase available in this project build.

const DESIGN_SIZE := Vector2(640.0, 360.0)
const PHASE_SCENE := "res://level_1.tscn"
const PLAYABLE_PHASES := {1: PHASE_SCENE, 2: "res://level_2.tscn", 3: "res://level_3.tscn", 4: "res://level_4.tscn", 6: "res://level_6.tscn"}
const MENU_SCENE := "res://Assets/04_Interface/Godot/main_menu.tscn"

const COLOR_INK := Color("17263d")
const COLOR_PANEL := Color("173b56")
const COLOR_PANEL_HOVER := Color("20536c")
const COLOR_TEAL := Color("21b9bf")
const COLOR_DISABLED := Color("65717d")
const COLOR_GOLD := Color("f4c95d")

var _design: Control

func _ready() -> void:
	_build_screen()
	resized.connect(_fit_design)
	_fit_design()

func _build_screen() -> void:
	_design = Control.new()
	_design.name = "Design"
	_design.size = DESIGN_SIZE
	add_child(_design)

	var background := TextureRect.new()
	background.name = "Background"
	background.texture = load("res://Assets/06_Story_Screens/discovery.png")
	background.size = DESIGN_SIZE
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_design.add_child(background)

	var shade := ColorRect.new()
	shade.name = "Shade"
	shade.size = DESIGN_SIZE
	shade.color = Color(0.035, 0.075, 0.13, 0.58)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_design.add_child(shade)

	_add_label("ESCOLHAM UMA FASE", Rect2(20, 15, 600, 34), 25, Color("fff1be"))
	_add_label("Escolham uma aventura", Rect2(20, 51, 600, 22), 13, Color("b9f5ec"))

	for index in range(6):
		var column := index % 3
		var row := floori(float(index) / 3.0)
		var rect := Rect2(46 + column * 184, 91 + row * 67, 168, 54)
		_add_phase_button(index + 1, rect)

	var back := Button.new()
	back.name = "Back"
	back.text = "VOLTAR AO MENU"
	back.position = Vector2(220, 251)
	back.size = Vector2(200, 42)
	_style_button(back, false, true)
	back.pressed.connect(func() -> void: get_tree().change_scene_to_file(MENU_SCENE))
	_design.add_child(back)
	back.grab_focus()

func _add_phase_button(phase_number: int, rect: Rect2) -> void:
	var button := Button.new()
	button.name = "Phase%d" % phase_number
	button.position = rect.position
	button.size = rect.size
	var available := PLAYABLE_PHASES.has(phase_number)
	button.text = "FASE %d   |   JOGAR" % phase_number if available else "FASE %d   |   EM BREVE" % phase_number
	button.disabled = not available
	_style_button(button, available)
	if available:
		button.pressed.connect(func() -> void: get_tree().change_scene_to_file(PLAYABLE_PHASES[phase_number]))
	_design.add_child(button)

func _style_button(button: Button, enabled: bool, compact: bool = false) -> void:
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if enabled else Control.CURSOR_ARROW
	button.add_theme_font_override("font", load("res://Assets/08_Fonts/PixelifySans.ttf"))
	button.add_theme_font_size_override("font_size", 13 if compact else 12)
	button.add_theme_color_override("font_color", Color("fff6d7"))
	button.add_theme_color_override("font_hover_color", Color("fff6d7"))
	button.add_theme_color_override("font_pressed_color", Color("fff6d7"))
	button.add_theme_color_override("font_disabled_color", Color("d0d5d8"))
	button.add_theme_color_override("font_focus_color", Color("fff6d7"))
	button.add_theme_constant_override("outline_size", 2)
	button.add_theme_color_override("font_outline_color", COLOR_INK)
	button.add_theme_stylebox_override("normal", _button_panel(COLOR_TEAL if enabled else COLOR_DISABLED, COLOR_GOLD if enabled else Color("90979e")))
	button.add_theme_stylebox_override("hover", _button_panel(COLOR_PANEL_HOVER, COLOR_GOLD))
	button.add_theme_stylebox_override("pressed", _button_panel(Color("157e92"), COLOR_GOLD))
	button.add_theme_stylebox_override("focus", _button_panel(COLOR_PANEL_HOVER, Color("fff1be")))
	button.add_theme_stylebox_override("disabled", _button_panel(COLOR_DISABLED, Color("90979e")))

func _button_panel(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(3)
	style.set_corner_radius_all(8)
	style.shadow_color = Color(0.02, 0.04, 0.08, 0.62)
	style.shadow_size = 4
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	return style

func _add_label(value: String, rect: Rect2, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.text = value
	label.position = rect.position
	label.size = rect.size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font", load("res://Assets/08_Fonts/PixelifySans.ttf"))
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", COLOR_INK)
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	_design.add_child(label)

func _fit_design() -> void:
	if not is_instance_valid(_design):
		return
	var factor := minf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
	_design.scale = Vector2(factor, factor)
	_design.position = (size - DESIGN_SIZE * factor) * 0.5
