extends Control
signal action_requested(action: StringName)

@onready var design: Control = $Design
var sound_state: Label

## Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: telas de interface dos assets.
func _ready() -> void:
	var fill:=ColorRect.new();fill.name="WindowBackdrop";fill.color=Color("081a26");fill.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(fill);move_child(fill,0);fill.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(_fit)
	_fit()
	var buttons := design.get_node_or_null("Buttons")
	if buttons:
		for child in buttons.get_children():
			if child is TextureButton:
				var button := child as TextureButton
				button.pressed.connect(_on_button_pressed.bind(StringName(button.name)))
		var first := buttons.get_child(0) as Control
		if first:
			first.grab_focus()
		if buttons.has_node("sound"):
			sound_state=Label.new();sound_state.name="SoundState";sound_state.position=Vector2(160,322);sound_state.size=Vector2(320,24)
			sound_state.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;sound_state.mouse_filter=Control.MOUSE_FILTER_IGNORE
			sound_state.add_theme_font_override("font",load("res://Assets/08_Fonts/NotoSans.ttf"));sound_state.add_theme_font_size_override("font_size",12)
			sound_state.add_theme_color_override("font_outline_color",Color("081a26"));sound_state.add_theme_constant_override("outline_size",3)
			design.add_child(sound_state);update_sound_state()
			var order: Array=[buttons.get_node("play"),buttons.get_node("how_to_play"),buttons.get_node("sound")]
			for i in order.size():
				order[i].focus_neighbor_bottom=order[i].get_path_to(order[(i+1)%order.size()])
				order[i].focus_neighbor_top=order[i].get_path_to(order[posmod(i-1,order.size())])


## Encaminha a ação do botão para seleção, instruções, menu ou som.
func _on_button_pressed(action: StringName) -> void:
	action_requested.emit(action)
	match action:
		&"play":
			get_tree().change_scene_to_file("res://phase_select.tscn")
		&"how_to_play":
			get_tree().change_scene_to_file("res://Assets/04_Interface/Godot/instructions.tscn")
		&"back":
			get_tree().change_scene_to_file("res://Assets/04_Interface/Godot/main_menu.tscn")
		&"sound":
			var master_bus := AudioServer.get_bus_index("Master")
			AudioServer.set_bus_mute(master_bus, not AudioServer.is_bus_mute(master_bus))
			update_sound_state()

## Centraliza e escala o desenho da interface preservando a proporção 640×360.
func _fit() -> void:
	if not is_instance_valid(design):
		return
	var factor := minf(size.x / 640.0, size.y / 360.0)
	design.scale = Vector2(factor, factor)
	design.position = (size - Vector2(640, 360) * factor) * 0.5


## Mostra o estado real do barramento principal, inclusive ao retornar de outra tela.
func update_sound_state() -> void:
	if sound_state==null:return
	var muted:=AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))
	sound_state.text="Som: desligado" if muted else "Som: ligado"
	design.get_node("Buttons/sound").tooltip_text="Ativar som" if muted else "Silenciar som"
