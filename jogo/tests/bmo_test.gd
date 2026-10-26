extends Node2D
## Isolated test only. No first-phase/menu/HUD/camera changes.
@export_range(1,2) var bmo_player_id: int = 1
@export var symbol_sequence: Array[int] = [0,2,1]

const Terminal = preload("res://tests/bmo_terminal.gd")
@onready var bmo: CoopPlayer = $BMO
@onready var marceline: CoopPlayer = $Marceline
@onready var symbol_terminal: Terminal = $SymbolTerminal
@onready var energy_terminal: Terminal = $EnergyTerminal
var recovery_count := 0

func _ready() -> void:
	DisplayServer.window_set_title("BMO — terminal e energia — sala de teste")
	bmo.player_id = bmo_player_id
	bmo.set_meta("player_id", bmo.player_id)
	marceline.player_id = 3 - bmo_player_id
	marceline.set_meta("player_id", marceline.player_id)
	symbol_terminal.sequence.assign(symbol_sequence)
	assert(not symbol_sequence.is_empty() and symbol_sequence.all(func(i: int): return i >= 0 and i < 3))
	var terrain := $Terrain as TileMap
	for column in 36:
		for row in range(25,33):
			terrain.set_cell(0,Vector2i(column,row),1,Vector2i(1,0 if row == 25 else 1))
	for column in [0,35]:
		for row in range(7,25): terrain.set_cell(0,Vector2i(column,row),1,Vector2i(1,1))
	for column in range(3,7): terrain.set_cell(0,Vector2i(column,20),1,Vector2i(1,1))
	for step in [Vector2i(11,23),Vector2i(13,21),Vector2i(15,19),Vector2i(17,17)]:
		for column in range(step.x,step.x+2): terrain.set_cell(0,Vector2i(column,step.y),1,Vector2i(1,0))
	var bmo_keys := "A/D: andar · Espaço/W: saltar · E: interagir" if bmo_player_id == 1 else "←/→: andar · ↑: saltar · Enter: interagir"
	var partner_keys := "←/→ e ↑ · Shift direito: flutuar" if marceline.player_id == 2 else "A/D e Espaço/W · Q: flutuar"
	$Instructions/Text.text = "BMO P%d — %s\nMarceline P%d — %s. Suba os degraus para ler a pista.\n1. Símbolos abrem a porta. 2. Conecte a energia. Esc cancela interações. F2 reinicia.\nInspector da raiz: Bmo Player Id = 1 ou 2 · Symbol Sequence: 0 círculo / 1 quadrado / 2 triângulo." % [bmo.player_id,bmo_keys,marceline.player_id,partner_keys]
	_build_clue()

func _build_clue() -> void:
	var clue := PanelContainer.new()
	clue.position = Vector2(472,174)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("172b38")
	style.border_color = Color("c7e2dc")
	style.set_border_width_all(2)
	style.set_content_margin_all(8)
	clue.add_theme_stylebox_override("panel",style)
	add_child(clue)
	var stack := VBoxContainer.new()
	clue.add_child(stack)
	stack.add_child(symbol_terminal._label("PISTA · MARCELINE",15))
	var row := HBoxContainer.new()
	stack.add_child(row)
	for i in symbol_sequence:
		var icon := TextureRect.new()
		icon.texture = Terminal.RUNES[i]
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(46,46)
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		row.add_child(icon)
	var names: Array[String] = []
	for i in symbol_sequence: names.append(Terminal.NAMES[i])
	stack.add_child(symbol_terminal._label(" → ".join(names),12))

func _process(_delta: float) -> void:
	for terminal in [symbol_terminal,energy_terminal]:
		if is_instance_valid(terminal): terminal.update_prompt(bmo)
	# Exactly one contextual receiver per press. Panel confirmation cannot also
	# activate the energy terminal, including when both ranges overlap.
	var owner := bmo.get("interaction_owner") as Node
	if is_instance_valid(owner):
		if owner.has_method("process_operator_input"): owner.call("process_operator_input")
		return
	if Input.is_action_just_pressed(bmo.get_interact_action()):
		var candidates: Array[Terminal] = []
		for terminal in [symbol_terminal,energy_terminal]:
			if is_instance_valid(terminal): candidates.append(terminal)
		candidates.sort_custom(func(a: Terminal,b: Terminal): return bmo.global_position.distance_squared_to(a.global_position) < bmo.global_position.distance_squared_to(b.global_position))
		for terminal in candidates:
			if terminal.interact(bmo): break

func _physics_process(_delta: float) -> void:
	if bmo.position.y > 740 or marceline.position.y > 740: recover_pair()

func recover_pair() -> void:
	bmo.call("reset_after_recovery")
	marceline.call("reset_after_recovery")
	bmo.position = Vector2(224,465)
	marceline.position = Vector2(344,465)
	recovery_count += 1

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	if event.keycode == KEY_F2:
		get_tree().reload_current_scene()
	elif event.keycode == KEY_ESCAPE:
		var owner := bmo.get("interaction_owner") as Node
		if is_instance_valid(owner) and owner.has_method("cancel"): owner.call("cancel")
