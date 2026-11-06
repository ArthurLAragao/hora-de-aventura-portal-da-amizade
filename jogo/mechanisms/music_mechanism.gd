extends Area2D
## Mecanismo musical contextual autorizado pela capacidade do personagem.

@export var required_ability: StringName = &"music"
@export var gate_path: NodePath
@onready var gate: CoopGate = get_node(gate_path) as CoopGate
@onready var prompt: Label = $Prompt
@onready var status: Label = $Status
@onready var music_sfx: AudioStreamPlayer2D = $MusicSFX

var activated := false
var _players: Array[CoopPlayer] = []

## Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: mecanismo musical autorizado por capacidade.
func _ready() -> void:
	body_entered.connect(_on_entered)
	body_exited.connect(_on_exited)
	_refresh()

## Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: mecanismo musical autorizado por capacidade.
func _process(_delta: float) -> void:
	for player in _players:
		if is_instance_valid(player) and Input.is_action_just_pressed(player.get_interact_action()):
			if activate(player): break

## Executa a ativação deste mecanismo e atualiza seu estado.
func activate(player: CoopPlayer) -> bool:
	if activated or not is_instance_valid(player) or not player.has_ability(required_ability) or not overlaps_body(player):
		return false
	if not player.has_method("play_music_interaction") or not is_instance_valid(gate):
		return false
	if not player.call("play_music_interaction"):
		return false
	activated = true
	gate.open_gate()
	music_sfx.play()
	_refresh()
	return true

## Registra o personagem que entrou no alcance do mecanismo. Contexto: mecanismo musical autorizado por capacidade.
func _on_entered(body: Node2D) -> void:
	if body is CoopPlayer and not _players.has(body):
		_players.append(body as CoopPlayer)
	_refresh()

## Remove o personagem que saiu do alcance do mecanismo. Contexto: mecanismo musical autorizado por capacidade.
func _on_exited(body: Node2D) -> void:
	_players.erase(body)
	_refresh()

## Sincroniza texto e disponibilidade do mecanismo com o estado atual.
func _refresh() -> void:
	status.text = "ATIVADO / PORTA ABERTA" if activated else "PAINEL MUSICAL / INATIVO"
	prompt.hide()
	if activated: return
	for player in _players:
		if is_instance_valid(player) and player.has_ability(required_ability):
			prompt.text = "E: tocar" if player.player_id == 1 else "Enter: tocar"
			prompt.show()
			break
