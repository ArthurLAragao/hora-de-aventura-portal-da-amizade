extends StaticBody2D
class_name CoopGate

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var gate_sprite: Sprite2D = $Sprite2D
@onready var open_sfx: AudioStreamPlayer2D = $OpenSFX
@export var closed_texture: Texture2D
@export var open_texture: Texture2D

var is_open := false

func _ready() -> void:
	_set_open_state(false)

func open_gate() -> void:
	_set_open_state(true)

func _set_open_state(open: bool) -> void:
	if is_open == open:
		return
	is_open = open
	if collision_shape != null:
		collision_shape.set_deferred("disabled", open)
	if gate_sprite != null:
		gate_sprite.texture = open_texture if open else closed_texture
	if open:
		open_sfx.play()
