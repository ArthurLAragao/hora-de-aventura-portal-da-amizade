extends AnimatableBody2D
class_name PushBlock

@export var push_speed: float = 155.0
@export var reset_fall_y: float = 700.0
@onready var push_sfx: AudioStreamPlayer2D = $PushSFX

## Optional constraints used by the revised phases; other scenes keep their prior movement rule.
@export var require_support:=false
@export var settled:=false
var reset_pending:=false
var blocked_by_edge:=false
var _start_transform: Transform2D
var _push_direction: float = 0.0

func _ready() -> void:
	add_to_group("pushable")
	collision_layer = 1
	collision_mask = 1
	sync_to_physics = false
	_start_transform = global_transform

func _physics_process(delta: float) -> void:
	if reset_pending:
		reset_to_start()
		return
	if settled:
		_push_direction=0.0
		return
	if not is_zero_approx(_push_direction):
		var motion:=Vector2(_push_direction*push_speed*delta,0.0)
		blocked_by_edge=require_support and not _supported_after(motion)
		if not blocked_by_edge: move_and_collide(motion)
		_push_direction = 0.0
	if global_position.y > reset_fall_y:
		reset_to_start()

func push(direction: float) -> void:
	if settled or reset_pending: return
	_push_direction = signf(direction)
	if is_instance_valid(push_sfx) and not push_sfx.playing:
		push_sfx.play()

func reset_to_start() -> void:
	var collider=$CollisionShape2D as CollisionShape2D
	var query:=PhysicsShapeQueryParameters2D.new()
	query.shape=collider.shape
	query.transform=_start_transform*collider.transform
	query.collision_mask=2
	query.exclude=[get_rid()]
	if not get_world_2d().direct_space_state.intersect_shape(query,1).is_empty():
		reset_pending=true
		_push_direction=0.0
		return
	reset_pending=false
	blocked_by_edge=false
	global_transform = _start_transform
	_push_direction = 0.0

func play_push_sound() -> void:
	if is_instance_valid(push_sfx) and not push_sfx.playing:
		push_sfx.play()

func _supported_after(motion: Vector2) -> bool:
	var collider=$CollisionShape2D as CollisionShape2D
	var half_height: float=collider.shape.size.y*0.5
	var foot: Vector2=collider.global_transform*Vector2(0,half_height)+motion
	var query:=PhysicsRayQueryParameters2D.create(foot-Vector2(0,1),foot+Vector2(0,4),1)
	query.exclude=[get_rid()]
	return not get_world_2d().direct_space_state.intersect_ray(query).is_empty()
