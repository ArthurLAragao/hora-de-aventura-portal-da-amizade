extends Area2D
class_name CoopLever

signal lever_activated(player_id: int)

@export var required_ability: StringName = &"lever"
@export var gate_path: NodePath
@export var one_shot: bool = true
@onready var prompt_label: Label = $Prompt
@onready var activation_sfx: AudioStreamPlayer2D = $ActivationSFX
var gate_to_open: Node
var _players_in_range: Dictionary[int, CoopPlayer] = {}
var _is_activated := false

func _ready() -> void:
	gate_to_open = get_node_or_null(gate_path)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_refresh_prompt()

func _process(_delta: float) -> void:
	for player in _players_in_range.values():
		if is_instance_valid(player) and Input.is_action_just_pressed(player.get_interact_action()):
			if activate(player):
				break

func activate(player: CoopPlayer) -> bool:
	if not is_instance_valid(player) or not player.has_ability(required_ability):
		return false
	if not overlaps_body(player) or (_is_activated and one_shot):
		return false
	if not is_instance_valid(gate_to_open) or not gate_to_open.has_method("open_gate"):
		return false
	_is_activated = true
	gate_to_open.open_gate()
	activation_sfx.play()
	player.play_lever_interaction()
	lever_activated.emit(player.player_id)
	_refresh_prompt()
	return true

func _on_body_entered(body: Node2D) -> void:
	if body is CoopPlayer:
		_players_in_range[body.get_instance_id()] = body as CoopPlayer
		_refresh_prompt()

func _on_body_exited(body: Node2D) -> void:
	_players_in_range.erase(body.get_instance_id())
	_refresh_prompt()

func _refresh_prompt() -> void:
	if prompt_label == null:
		return
	prompt_label.visible = false
	if _is_activated and one_shot:
		return
	for player in _players_in_range.values():
		if is_instance_valid(player) and player.has_ability(required_ability):
			prompt_label.text = "E" if player.player_id == 1 else "Enter"
			prompt_label.visible = true
			return
