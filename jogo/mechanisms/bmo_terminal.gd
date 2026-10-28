extends Area2D
signal activated
## Terminal contextual de símbolos/energia, com bloqueio apenas do operador.
enum Mode { SYMBOLS, ENERGY }
@export var mode: Mode = Mode.SYMBOLS
@export var sequence: Array[int] = [0, 2, 1]
@export var gate_path: NodePath
@export var indicator_path: NodePath
@export var battery_path: NodePath

const RUNES = [preload("res://Assets/03_Objects_and_Puzzles/sprites/rune_circle.png"), preload("res://Assets/03_Objects_and_Puzzles/sprites/rune_square.png"), preload("res://Assets/03_Objects_and_Puzzles/sprites/rune_triangle.png")]
const NAMES = ["círculo", "quadrado", "triângulo"]
const ON = preload("res://Assets/03_Objects_and_Puzzles/sprites/terminal_on.png")
const RECEIVER_ON = preload("res://Assets/03_Objects_and_Puzzles/sprites/receiver_on.png")
const BATTERY_ON = preload("res://Assets/03_Objects_and_Puzzles/sprites/battery_on.png")
const FONT = preload("res://Assets/08_Fonts/NotoSans.ttf")
var operator: CoopPlayer
var panel_open := false
var energized := false
var solved := false
var activation_count := 0
var selection := 0
var entered: Array[int] = []
var attempts := 0
var _armed := false
var pending := false
var panel: PanelContainer
var choices: Array[PanelContainer] = []
var progress: Label
var help: Label
var feedback: Label
@onready var prompt: Label = $Prompt
@onready var status: Label = $Status
@onready var sprite: Sprite2D = $Sprite2D

## Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: painel de símbolos e conexão de energia.
func _ready() -> void:
	assert(not sequence.is_empty() and sequence.all(func(i: int): return i >= 0 and i < 3))
	if mode == Mode.SYMBOLS:
		_build_panel()
	status.text = "SÍMBOLOS: porta fechada" if mode == Mode.SYMBOLS else "ENERGIA: desligada"

## Verifica alcance, capacidade e disponibilidade para uma interação contextual.
func can_interact(actor: CoopPlayer) -> bool:
	return is_instance_valid(actor) and actor.has_ability(&"terminal" if mode == Mode.SYMBOLS else &"energy") and actor.has_method("begin_interaction") and overlaps_body(actor) and actor.is_on_floor() and not actor.movement_locked and not solved and not energized and not pending

## Inicia a interação local e registra o personagem proprietário.
func interact(actor: CoopPlayer) -> bool:
	if not can_interact(actor): return false
	if not actor.call("begin_interaction", self, &"terminal" if mode == Mode.SYMBOLS else &"connect_power"): return false
	operator = actor
	actor.face_direction(global_position.x - actor.global_position.x)
	if mode == Mode.ENERGY:
		pending = true
		status.text = "Conectando energia… Esc cancela"
	else:
		panel_open = true
		status.text = "SÍMBOLOS: em operação"
		_armed = false
		selection = 0
		entered.clear()
		feedback.text = "Leia a pista no painel elevado."
		help.text = ("A/D: escolher  •  E: confirmar" if actor.player_id == 1 else "←/→: escolher  •  Enter: confirmar") + "\nEsc: cancelar e voltar a andar"
		panel.show()
		_refresh_panel()
	return true

## Processa somente as entradas do operador, exigindo soltar a tecla usada para abrir o painel.
func process_operator_input() -> void:
	if not panel_open or not is_instance_valid(operator): return
	if not overlaps_body(operator):
		cancel()
		return
	# A held opening key must be released before it can confirm anything.
	if not _armed:
		_armed = not Input.is_action_pressed(operator.get_interact_action())
		return
	var prefix := "p%d" % operator.player_id
	if Input.is_action_just_pressed(prefix + "_left"):
		selection = posmod(selection - 1, 3)
	if Input.is_action_just_pressed(prefix + "_right"):
		selection = posmod(selection + 1, 3)
	if Input.is_action_just_pressed(operator.get_interact_action()):
		entered.append(selection)
		if entered.size() == sequence.size():
			attempts += 1
			if entered == sequence:
				solved = true
				activation_count += 1
				sprite.texture = ON
				status.text = "✓ SÍMBOLOS: porta aberta"
				var gate := get_node_or_null(gate_path)
				if gate != null: gate.call("open_gate")
				operator.call("finish_interaction", self, true)
				activated.emit()
				return
			entered.clear()
			feedback.text = "Ainda não. Tente a sequência da pista."
	_refresh_panel()

## Cancela a ação corrente e libera as referências/controles pertencentes a este mecanismo.
func cancel() -> void:
	if is_instance_valid(operator): operator.call("finish_interaction", self, false)
	else: action_finished(null, false)

## Recebe sucesso/cancelamento da animação e conclui a operação sem duplicar efeitos.
func action_finished(_actor: CoopPlayer, completed: bool) -> void:
	var newly_energized := false
	if mode == Mode.ENERGY and pending:
		pending = false
		if completed and not energized:
			energized = true
			newly_energized = true
			activation_count += 1
			sprite.texture = ON
			var indicator := get_node_or_null(indicator_path) as Sprite2D
			if indicator != null: indicator.texture = RECEIVER_ON
			var battery := get_node_or_null(battery_path) as Sprite2D
			if battery != null: battery.texture = BATTERY_ON
		status.text = "✓ ENERGIA: conectada" if energized else "Conexão cancelada; tente novamente."
	elif mode == Mode.SYMBOLS:
		panel_open = false
		panel.hide()
		entered.clear()
		_armed = false
		if not solved: status.text = "Terminal fechado; pode tentar novamente."
	operator = null
	if newly_energized: activated.emit()

## Atualiza a indicação contextual com a tecla do jogador e a disponibilidade da ação.
func update_prompt(actor: CoopPlayer) -> void:
	prompt.text = ""
	if can_interact(actor):
		prompt.text = ("E" if actor.player_id == 1 else "Enter") + (": símbolos" if mode == Mode.SYMBOLS else ": energia")
	elif not solved and not energized and not pending and get_overlapping_bodies().size() > 0 and not panel_open:
		prompt.text = "BMO opera este terminal"

## Cria um rótulo do painel com fonte, tamanho e texto configurados.
func _label(text: String, size: int = 16) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", size)
	return label

## Cria o estilo de fundo/borda usado nos elementos do painel.
func _style(selected: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("314351") if not selected else Color("526d61")
	style.border_color = Color("e4f7f0") if selected else Color("526878")
	style.set_border_width_all(3 if selected else 1)
	style.set_content_margin_all(8)
	return style

## Monta o painel de símbolos com seleção, progresso e instruções do operador.
func _build_panel() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	panel = PanelContainer.new()
	panel.position = Vector2(32, 138)
	panel.custom_minimum_size = Vector2(410, 276)
	var style := _style(false)
	style.bg_color = Color("172b38")
	style.set_content_margin_all(14)
	panel.add_theme_stylebox_override("panel", style)
	layer.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	panel.add_child(content)
	content.add_child(_label("BMO · TERMINAL DE SÍMBOLOS", 18))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	content.add_child(row)
	for i in 3:
		var choice := PanelContainer.new()
		choice.custom_minimum_size = Vector2(114, 98)
		choices.append(choice)
		row.add_child(choice)
		var stack := VBoxContainer.new()
		choice.add_child(stack)
		var icon := TextureRect.new()
		icon.texture = RUNES[i]
		icon.custom_minimum_size = Vector2(48,48)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		stack.add_child(icon)
		var name_label := _label(NAMES[i], 14)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stack.add_child(name_label)
	progress = _label("")
	feedback = _label("", 14)
	help = _label("", 14)
	content.add_child(progress)
	content.add_child(feedback)
	content.add_child(help)
	panel.hide()

## Atualiza seleção e sequência apresentada no painel.
func _refresh_panel() -> void:
	for i in 3: choices[i].add_theme_stylebox_override("panel", _style(i == selection))
	var words: Array[String] = []
	for i in entered: words.append(NAMES[i])
	progress.text = "Sequência %d/%d: %s" % [entered.size(), sequence.size(), " → ".join(words) if not words.is_empty() else "—"]

## Limpa referências/estado temporário ao retirar o componente da árvore. Contexto: painel de símbolos e conexão de energia.
func _exit_tree() -> void:
	if is_instance_valid(operator) and operator.get("interaction_owner") == self:
		operator.call("finish_interaction", self, false)
