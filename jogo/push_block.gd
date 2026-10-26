extends AnimatableBody2D
class_name PushBlock

@export var push_speed: float = 155.0
@export var reset_fall_y: float = 700.0
@onready var push_sfx: AudioStreamPlayer2D = $PushSFX

var _start_transform: Transform2D
var _push_direction: float = 0.0

func _ready() -> void:
	add_to_group("pushable")
	collision_layer = 1
	collision_mask = 1
	sync_to_physics = false
	_start_transform = global_transform

func _physics_process(delta: float) -> void:
	if not is_zero_approx(_push_direction):
		move_and_collide(Vector2(_push_direction * push_speed * delta, 0.0))
		_push_direction = 0.0
	if global_position.y > reset_fall_y:
		reset_to_start()

func push(direction: float) -> void:
	_push_direction = signf(direction)
	if is_instance_valid(push_sfx) and not push_sfx.playing:
		push_sfx.play()

func reset_to_start() -> void:
	global_transform = _start_transform
	_push_direction = 0.0

func play_push_sound() -> void:
	if is_instance_valid(push_sfx) and not push_sfx.playing:
		push_sfx.play()
