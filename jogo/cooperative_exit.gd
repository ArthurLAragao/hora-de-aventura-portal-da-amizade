extends Area2D
class_name CooperativeExit

signal level_completed

@export var crystal_path: NodePath
@onready var completion_label: Label = $Completion
var crystal: FriendshipCrystal

var _players_in_exit: Dictionary[int, bool] = {}
var _completed := false
var _crystal_collected := false

func _ready() -> void:
	crystal = get_node_or_null(crystal_path) as FriendshipCrystal
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if completion_label != null:
		completion_label.visible = false
	if crystal != null:
		_crystal_collected = crystal.is_collected
		crystal.collected.connect(_on_crystal_collected)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		_players_in_exit[int(body.get_meta("player_id", 0))] = true
		_try_complete()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("players"):
		_players_in_exit.erase(int(body.get_meta("player_id", 0)))

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

func _on_crystal_collected() -> void:
	_crystal_collected = true
	_try_complete()
