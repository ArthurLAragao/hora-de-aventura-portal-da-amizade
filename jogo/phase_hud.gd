extends CanvasLayer
class_name PhaseHud

@onready var hint_label: Label = $Hints
@onready var crystal_label: Label = $CrystalStatus
@onready var message_label: Label = $Message
@onready var bridge_hint: Label = $JakeBridgeHint
@onready var return_button: Button = $ReturnToPhases
@onready var message_timer: Timer = $MessageTimer

func _ready() -> void:
	_add_hud_backplate()
	hint_label.text = "Finn: A/D andar | Espaço pular | E interagir | Segure Q para empurrar | R restaurar tronco\nJake: Setas andar | Cima pular | Enter interagir | Shift direito: ponte"
	crystal_label.text = "Cristal da Amizade: nao recuperado"
	message_label.visible = false
	bridge_hint.visible = false
	return_button.visible = false
	return_button.pressed.connect(_return_to_phase_select)
	message_timer.timeout.connect(_hide_timed_message)
	for label in [hint_label, crystal_label, bridge_hint, message_label, return_button]:
		label.add_theme_color_override("font_outline_color", Color(0.08, 0.12, 0.22, 1.0))
		label.add_theme_constant_override("outline_size", 3)

func _add_hud_backplate() -> void:
	var panel := Panel.new()
	panel.name = "HUDBackplate"
	panel.position = Vector2(6.0, 6.0)
	panel.size = Vector2(790.0, 144.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.075, 0.13, 0.78)
	style.border_color = Color(0.38, 0.83, 0.78, 0.88)
	style.set_border_width_all(2)
	style.set_corner_radius_all(7)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.3)
	style.shadow_size = 3
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	move_child(panel, 0)

func set_crystal_collected() -> void:
	crystal_label.text = "Cristal da Amizade recuperado!"

func show_message(message: String, duration: float = 0.0) -> void:
	message_timer.stop()
	message_label.text = message
	message_label.visible = true
	if duration > 0.0:
		message_timer.start(duration)

func _hide_timed_message() -> void:
	message_label.visible = false

func set_jake_bridge_prompt(visible: bool) -> void:
	bridge_hint.visible = visible

func show_completion() -> void:
	show_message("Cristal recuperado! Fase concluída!")
	return_button.visible = true
	return_button.grab_focus()

func _return_to_phase_select() -> void:
	get_tree().change_scene_to_file("res://phase_select.tscn")
