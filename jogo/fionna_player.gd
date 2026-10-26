extends "res://player.gd"
## Reuses the existing movement and contact-based push requests without changing Finn.
var interaction_owner: Node
var _crank_left := 0.0
var _jump_start_left := 0.0

func _physics_process(delta: float) -> void:
	_jump_start_left = maxf(0.0, _jump_start_left - delta)
	if movement_locked and animation_override == &"crank":
		if not is_instance_valid(interaction_owner) or not interaction_owner.is_inside_tree():
			finish_crank(interaction_owner,false)
		else:
			velocity = Vector2.ZERO
			_jump_buffer_left = 0.0
			_coyote_left = 0.0
			_play_motion_animation(&"crank")
			_crank_left = maxf(0.0,_crank_left-delta)
			if _crank_left <= 0.0:
				# A broken/paused/looping clip cancels, rather than awarding progress.
				finish_crank(interaction_owner,false)
		return
	super._physics_process(delta)

func _start_jump() -> void:
	super._start_jump()
	_jump_start_left = get_animation_duration(&"jump_start")

func _update_animation() -> void:
	if movement_locked and animation_override != &"":
		_play_motion_animation(animation_override)
	elif not is_on_floor() or velocity.y < -1.0:
		_play_motion_animation((&"jump_start" if _jump_start_left > 0.0 else &"jump") if velocity.y < -1.0 else &"fall")
	elif _pushing:
		_play_motion_animation(&"push")
	elif absf(velocity.x) > 8.0:
		_play_motion_animation(&"walk")
	elif _landing_left > 0.0:
		_play_motion_animation(&"land")
	else:
		_play_motion_animation(&"idle")

func _push_nearby_block() -> void:
	# Fionna pushes by walking against the marked block, not by Q/Shift.
	pass

func _try_push_from_walk(prefix: String) -> void:
	if not has_ability(&"push") or not is_on_floor() or is_zero_approx(Input.get_axis(prefix+"_left",prefix+"_right")): return
	for index in get_slide_collision_count():
		var contact := get_slide_collision(index)
		var target := contact.get_collider()
		# Standing on the crate is not a horizontal pushing attempt.
		if target is PushBlock and absf(contact.get_normal().x)>0.7 and signf((target as Node2D).global_position.x-global_position.x)==_facing:
			_request_push(target as PushBlock)

func begin_crank(owner: Node) -> bool:
	if not has_ability(&"crank") or movement_locked or is_instance_valid(interaction_owner) or not is_on_floor(): return false
	if not is_instance_valid(owner) or not animated_sprite.sprite_frames.has_animation(&"crank"): return false
	interaction_owner = owner
	movement_locked = true
	animation_override = &"crank"
	_crank_left = clampf(get_animation_duration(&"crank")+0.2,0.2,2.0)
	_jump_buffer_left = 0.0
	_coyote_left = 0.0
	_jump_start_left = 0.0
	_push_target = null
	_pushing = false
	velocity = Vector2.ZERO
	animated_sprite.play(&"crank")
	animated_sprite.set_frame_and_progress(0,0.0)
	return true

func finish_crank(owner: Node, completed: bool) -> void:
	if owner != interaction_owner: return
	var previous := interaction_owner
	interaction_owner = null
	movement_locked = false
	animation_override = &""
	_crank_left = 0.0
	_jump_buffer_left = 0.0
	_coyote_left = 0.0
	_landing_left = 0.0
	velocity = Vector2.ZERO
	_play_motion_animation(&"idle")
	if is_instance_valid(previous) and previous.has_method("action_finished"):
		previous.call("action_finished",self,completed)

func _on_animation_finished() -> void:
	super._on_animation_finished()
	if movement_locked and animation_override == &"crank" and animated_sprite.animation == &"crank": finish_crank(interaction_owner,true)

func reset_after_recovery() -> void:
	finish_crank(interaction_owner,false)
	_jump_start_left = 0.0
	_interaction_left = 0.0
	_push_target = null
	_pushing = false
	_jump_buffer_left = 0.0
	_coyote_left = 0.0
	_landing_left = 0.0
	velocity = Vector2.ZERO
	movement_locked = false
	animation_override = &""
	_play_motion_animation(&"idle")
