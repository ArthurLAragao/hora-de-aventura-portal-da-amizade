extends Area2D
class_name CooperativeExit

signal level_completed

@export var crystal_path: NodePath
@onready var completion_label: Label = $Completion
var crystal: FriendshipCrystal

var _players_in_exit: Dictionary[int, bool] = {}
var _completed := false
var _crystal_collected := false

## Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: saída conjunta condicionada ao cristal.
func _ready() -> void:
	crystal = get_node_or_null(crystal_path) as FriendshipCrystal
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if completion_label != null:
		completion_label.visible = false
	if crystal != null:
		_crystal_collected = crystal.is_collected
		crystal.collected.connect(_on_crystal_collected)

## Registra a entrada de um corpo elegível na área e reavalia a ação local. Contexto: saída conjunta condicionada ao cristal.
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		_players_in_exit[int(body.get_meta("player_id", 0))] = true
		_try_complete()

## Remove o corpo que saiu da área e atualiza as condições locais. Contexto: saída conjunta condicionada ao cristal.
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("players"):
		_players_in_exit.erase(int(body.get_meta("player_id", 0)))

## Verifica cristal e presença conjunta antes de emitir a conclusão uma única vez.
func _try_complete() -> void:
	if _completed or not _crystal_collected:
		return
	if not _players_in_exit.get(1, false) or not _players_in_exit.get(2, false):
		return
	_completed = true
	if completion_label != null:
		completion_label.text = "Cristal recuperado! Fase concluida!"
		completion_label.visible = true
	level_completed.emit()

## Registra a coleta para a condição de saída.
func _on_crystal_collected() -> void:
	_crystal_collected = true
	_try_complete()
