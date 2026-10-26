extends Area2D
class_name PressurePlate

signal plate_activated
signal plate_deactivated
signal activation_changed(active: bool)

@export var accepts_players: bool = true
@export var accepts_pushables: bool = false
@export_range(0, 2) var required_player_id: int = 0
@onready var plate_sprite: Sprite2D = $Sprite2D
@onready var press_sfx: AudioStreamPlayer2D = $PressSFX
@export var raised_texture: Texture2D
@export var pressed_texture: Texture2D

var _occupants: Dictionary[int, Node2D] = {}

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	monitoring = true
	_set_visual(false)

func is_active() -> bool:
	return not _occupants.is_empty()

func _on_body_entered(body: Node2D) -> void:
	if not _is_accepted(body):
		return
	var was_active := is_active()
	_occupants[body.get_instance_id()] = body
	if not was_active:
		_set_visual(true)
		plate_activated.emit()
		activation_changed.emit(true)

func _on_body_exited(body: Node2D) -> void:
	var was_active := is_active()
	_occupants.erase(body.get_instance_id())
	if was_active and not is_active():
		_set_visual(false)
		plate_deactivated.emit()
		activation_changed.emit(false)

func _is_accepted(body: Node2D) -> bool:
	if body.is_in_group("players") and accepts_players:
		return required_player_id == 0 or int(body.get_meta("player_id", 0)) == required_player_id
	return accepts_pushables and body.is_in_group("pushable")

func _set_visual(pressed: bool) -> void:
	if plate_sprite != null:
		plate_sprite.texture = pressed_texture if pressed else raised_texture
	if pressed:
		press_sfx.play()
