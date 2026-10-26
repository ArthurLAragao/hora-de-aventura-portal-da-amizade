extends Area2D
class_name CoopCheckpoint

signal checkpoint_activated

@onready var player_one_spawn: Marker2D = $FinnSpawn
@onready var player_two_spawn: Marker2D = $JakeSpawn
@onready var checkpoint_sprite: Sprite2D = $Sprite2D
@onready var activation_sfx: AudioStreamPlayer2D = $ActivationSFX
@export var inactive_texture: Texture2D
@export var active_texture: Texture2D
## Phase 1: the existing permanent passage must already be open.
@export var required_passage_path: NodePath = NodePath("../PermanentBridge")

var activated := false
var _accepting_entries := false
var _recovery_in_progress := false
var _required_passage: PermanentBridge

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_required_passage = get_node_or_null(required_passage_path) as PermanentBridge
	if checkpoint_sprite != null:
		checkpoint_sprite.texture = inactive_texture
	_arm_after_startup.call_deferred()

func _arm_after_startup() -> void:
	# Initial overlap is not a checkpoint conquest. A fresh area entry is needed.
	await get_tree().physics_frame
	await get_tree().physics_frame
	_accepting_entries = true

func set_recovery_in_progress(value: bool) -> void:
	_recovery_in_progress = value

func get_respawn_positions() -> Array[Vector2]:
	if not activated or not is_instance_valid(player_one_spawn) or not is_instance_valid(player_two_spawn):
		return []
	return [player_one_spawn.global_position, player_two_spawn.global_position]

func _on_body_entered(body: Node2D) -> void:
	if activated or not _accepting_entries or _recovery_in_progress:
		return
	if not body is CoopPlayer or not overlaps_body(body):
		return
	if not is_instance_valid(_required_passage) or not _required_passage.visible or _required_passage.collision_layer == 0:
		return
	activated = true
	if checkpoint_sprite != null:
		checkpoint_sprite.texture = active_texture
	activation_sfx.play()
	checkpoint_activated.emit()
