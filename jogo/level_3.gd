extends "res://imported_phase_runtime.gd"

@export var symbol_sequence: Array[int] = [0, 2, 1]

const Terminal = preload("res://tests/bmo_terminal.gd")

@onready var marceline: CoopPlayer = $Players/Marceline
@onready var bmo: CoopPlayer = $Players/BMO
@onready var symbol_terminal: Terminal = $SymbolTerminal
@onready var energy_terminal: Terminal = $EnergyTerminal

func _ready() -> void:
	configure_imported_phase()
	# Define Marceline como P1 e BMO como P2 (mesma lógica das salas de teste)
	marceline.player_id = 1
	marceline.set_meta("player_id", 1)
	bmo.player_id = 2
	bmo.set_meta("player_id", 2)

	if is_instance_valid(symbol_terminal):
		symbol_terminal.sequence.assign(symbol_sequence)
		_build_clue()

func _build_clue() -> void:
	var clue := PanelContainer.new()
	clue.position = Vector2(520, 180)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("172b38")
	style.border_color = Color("c7e2dc")
	style.set_border_width_all(2)
	style.set_content_margin_all(8)
	clue.add_theme_stylebox_override("panel", style)
	add_child(clue)

	var stack := VBoxContainer.new()
	clue.add_child(stack)
	stack.add_child(symbol_terminal._label("PISTA · MARCELINE", 15))

	var row := HBoxContainer.new()
	stack.add_child(row)
	for i in symbol_sequence:
		var icon := TextureRect.new()
		icon.texture = Terminal.RUNES[i]
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(46, 46)
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		row.add_child(icon)

	var names: Array[String] = []
	for i in symbol_sequence:
		names.append(Terminal.NAMES[i])
	stack.add_child(symbol_terminal._label(" → ".join(names), 12))

func _process(_delta: float) -> void:
	for terminal in [symbol_terminal, energy_terminal]:
		if is_instance_valid(terminal):
			terminal.update_prompt(bmo)

	var owner := bmo.get("interaction_owner") as Node
	if is_instance_valid(owner):
		if owner.has_method("process_operator_input"):
			owner.call("process_operator_input")
		return

	if Input.is_action_just_pressed(bmo.get_interact_action()):
		var candidates: Array[Terminal] = []
		for terminal in [symbol_terminal, energy_terminal]:
			if is_instance_valid(terminal):
				candidates.append(terminal)
		candidates.sort_custom(func(a: Terminal, b: Terminal):
			return bmo.global_position.distance_squared_to(a.global_position) < bmo.global_position.distance_squared_to(b.global_position)
		)
		for terminal in candidates:
			if terminal.interact(bmo):
				break

func _unhandled_key_input(event: InputEvent) -> void:
	super._unhandled_key_input(event)
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_ESCAPE:
		var owner := bmo.get("interaction_owner") as Node
		if is_instance_valid(owner) and owner.has_method("cancel"):
			owner.call("cancel")
