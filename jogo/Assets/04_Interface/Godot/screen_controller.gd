extends Control
signal action_requested(action: StringName)

@onready var design: Control = $Design

## Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: telas de interface dos assets.
func _ready() -> void:
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

## Centraliza e escala o desenho da interface preservando a proporção 640×360.
func _fit() -> void:
	if not is_instance_valid(design):
		return
	var factor := minf(size.x / 640.0, size.y / 360.0)
	design.scale = Vector2(factor, factor)
	design.position = (size - Vector2(640, 360) * factor) * 0.5

