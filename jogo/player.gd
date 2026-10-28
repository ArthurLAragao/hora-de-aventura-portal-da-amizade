extends CharacterBody2D
class_name CoopPlayer

@export_range(1, 2) var player_id: int = 1
@export var character_id: StringName = &""
@export var allowed_abilities: Array[StringName] = []
@export var speed: float = 180.0
@export var jump_velocity: float = -360.0
## Zero preserves the timing of characters not yet configured.
@export_range(0.0, 0.25, 0.01) var coyote_time: float = 0.0
@export_range(0.0, 0.25, 0.01) var jump_buffer_time: float = 0.0
@export var max_partner_distance: float = 680.0
@export var movement_locked: bool = false
@export var animation_override: StringName = &""
## Visual wrappers can reuse their original scene without moving its sprite.
@export var animated_sprite_path: NodePath = ^"AnimatedSprite2D"

var gravity: float = float(ProjectSettings.get_setting("physics/2d/default_gravity"))
var _facing := 1.0
var _coyote_left := 0.0
var _jump_buffer_left := 0.0
var _landing_left := 0.0
var _interaction_left := 0.0
var _interaction_animation: StringName = &""
var _push_target: PushBlock
var _push_target_position := Vector2.ZERO
var _pushing := false

@onready var animated_sprite: AnimatedSprite2D = get_node(animated_sprite_path) as AnimatedSprite2D

func _ready() -> void:
	add_to_group("players")
	set_meta("player_id", player_id)
	collision_layer = 2
	collision_mask = 1
	animated_sprite.z_index=maxi(animated_sprite.z_index,2)
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	var prefix := "p1" if player_id == 1 else "p2"
	if movement_locked:
		velocity = Vector2.ZERO
		_coyote_left = 0.0
		_jump_buffer_left = 0.0
		if animation_override != &"":
			_play_if_available(animation_override)
		else:
			_update_animation()
		return

	_landing_left = maxf(0.0, _landing_left - delta)
	_interaction_left = maxf(0.0, _interaction_left - delta)
	_jump_buffer_left = maxf(0.0, _jump_buffer_left - delta)
	var grounded_before := is_on_floor()
	if grounded_before and velocity.y >= 0.0:
		_coyote_left = coyote_time
	else:
		_coyote_left = maxf(0.0, _coyote_left - delta)
	var jump_pressed := Input.is_action_just_pressed(prefix + "_jump")
	if jump_pressed:
		_jump_buffer_left = jump_buffer_time
	if not grounded_before:
		_apply_air_gravity(delta)
	var jumped := false
	if (jump_pressed or _jump_buffer_left > 0.0) and ((grounded_before and velocity.y >= 0.0) or _coyote_left > 0.0):
		_start_jump()
		jumped = true

	var direction := Input.get_axis(prefix + "_left", prefix + "_right")
	direction = _limit_direction_from_partner(direction)
	velocity.x = direction * speed if not is_zero_approx(direction) else move_toward(velocity.x, 0.0, speed * 8.0 * delta)
	if not is_zero_approx(direction):
		face_direction(direction)

	# PushBlock processes a request on its physics tick. The pose requires
	# observed displacement; a request against a wall must not look successful.
	_pushing = is_instance_valid(_push_target) and absf(_push_target.global_position.x - _push_target_position.x) > 0.05
	_push_target = null
	move_and_slide()
	if not jumped and is_on_floor() and _jump_buffer_left > 0.0:
		_start_jump()
		jumped = true
	if not grounded_before and is_on_floor() and not jumped:
		_landing_left = get_animation_duration(&"land")
	_try_push_from_walk(prefix)
	if has_ability(&"push") and Input.is_action_pressed(get_ability_action()):
		_push_nearby_block()
	if has_ability(&"push") and Input.is_action_pressed(get_reset_action()):
		_reset_nearby_pushable()
	_update_animation()

func _apply_air_gravity(delta: float) -> void:
	velocity.y += gravity * delta

func _start_jump() -> void:
	velocity.y = jump_velocity
	_coyote_left = 0.0
	_jump_buffer_left = 0.0
	_landing_left = 0.0
	_interaction_left = 0.0

func face_direction(direction: float) -> void:
	if not is_zero_approx(direction):
		_facing = signf(direction)
		animated_sprite.flip_h = _facing < 0.0

func has_ability(ability: StringName) -> bool:
	return allowed_abilities.has(ability)

func _limit_direction_from_partner(direction: float) -> float:
	if is_zero_approx(direction):
		return direction
	for candidate in get_tree().get_nodes_in_group("players"):
		if candidate == self or not candidate is Node2D:
			continue
		var horizontal_gap := global_position.x - (candidate as Node2D).global_position.x
		if absf(horizontal_gap) >= max_partner_distance and signf(direction) == signf(horizontal_gap):
			return 0.0
	return direction

func _update_animation() -> void:
	if character_id not in [&"finn", &"jake"]:
		# Keep compatibility with unconfigured scenes.
		if not is_on_floor():
			_play_if_available(&"jump")
		elif absf(velocity.x) > 8.0:
			_play_if_available(&"run" if animated_sprite.sprite_frames.has_animation(&"run") else &"walk")
		else:
			_play_if_available(&"idle")
		return
	if not is_on_floor() or velocity.y < -1.0:
		_interaction_left = 0.0
		_play_motion_animation(&"jump" if velocity.y < -1.0 else &"fall")
	elif _interaction_left > 0.0:
		_play_motion_animation(_interaction_animation)
	elif _pushing:
		_play_motion_animation(&"push")
	elif absf(velocity.x) > 8.0:
		_play_motion_animation(&"walk")
	elif _landing_left > 0.0:
		_play_motion_animation(&"land")
	else:
		_play_motion_animation(&"idle")

func _play_motion_animation(animation_name: StringName) -> void:
	var frames := animated_sprite.sprite_frames
	if frames == null or not frames.has_animation(animation_name):
		return
	if animated_sprite.animation != animation_name:
		animated_sprite.play(animation_name)
	elif frames.get_animation_loop(animation_name) and not animated_sprite.is_playing():
		animated_sprite.play(animation_name)

func _play_if_available(animation_name: StringName) -> void:
	if animated_sprite.sprite_frames == null or not animated_sprite.sprite_frames.has_animation(animation_name):
		return
	if animated_sprite.animation != animation_name or not animated_sprite.is_playing():
		animated_sprite.play(animation_name)

func play_lever_interaction() -> void:
	if not has_ability(&"lever") or character_id != &"finn":
		return
	_interaction_animation = &"pull_lever"
	_interaction_left = get_animation_duration(_interaction_animation) + 0.1
	animated_sprite.play(_interaction_animation)
	animated_sprite.set_frame_and_progress(0, 0.0)

func get_animation_duration(animation_name: StringName) -> float:
	var frames := animated_sprite.sprite_frames
	if frames == null or not frames.has_animation(animation_name):
		return 0.0
	var duration := 0.0
	for frame in frames.get_frame_count(animation_name):
		duration += frames.get_frame_duration(animation_name, frame)
	return duration / maxf(frames.get_animation_speed(animation_name), 0.01)

func _on_animation_finished() -> void:
	if character_id == &"finn" and animated_sprite.animation == _interaction_animation:
		_interaction_left = 0.0

func _try_push_from_walk(prefix: String) -> void:
	if not has_ability(&"push") or not is_on_floor():
		return
	if not Input.is_action_pressed(prefix + "_right") and not Input.is_action_pressed(prefix + "_left"):
		return
	for index in get_slide_collision_count():
		var target := get_slide_collision(index).get_collider()
		if target is PushBlock and signf((target as Node2D).global_position.x - global_position.x) == _facing:
			_request_push(target as PushBlock)

func _push_nearby_block() -> void:
	if not is_on_floor():
		return
	# Arm's reach only: no remote pushing through empty space or walls.
	var contact := KinematicCollision2D.new()
	if test_move(global_transform, Vector2(_facing * 8.0, 0.0), contact) and contact.get_collider() is PushBlock:
		_request_push(contact.get_collider() as PushBlock)

func _request_push(block: PushBlock) -> void:
	block.push(_facing)
	_push_target = block
	_push_target_position = block.global_position

func _reset_nearby_pushable() -> void:
	for target in get_tree().get_nodes_in_group("pushable"):
		if target is Node2D and global_position.distance_to((target as Node2D).global_position) <= 180.0:
			if target.has_method("reset_to_start"):
				target.reset_to_start()

func get_interact_action() -> StringName:
	return &"p1_interact" if player_id == 1 else &"p2_interact"

func get_ability_action() -> StringName:
	return &"p1_ability" if player_id == 1 else &"p2_ability"

func get_reset_action() -> StringName:
	return &"p1_reset" if player_id == 1 else &"p2_reset"
