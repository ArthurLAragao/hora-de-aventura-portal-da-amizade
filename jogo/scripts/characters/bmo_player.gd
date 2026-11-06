extends "res://scripts/characters/player.gd"
## Movement remains shared; this script owns only BMO poses and local action locks.
var interaction_owner: Node
var _action_left := 0.0
var _jump_start_left := 0.0

## Atualiza a lógica em passos fixos de física; delta representa segundos. Contexto: ações locais de terminal e energia de BMO.
func _physics_process(delta: float) -> void:
	_jump_start_left = maxf(0.0, _jump_start_left - delta)
	if movement_locked and animation_override in [&"terminal", &"connect_power"]:
		if not is_instance_valid(interaction_owner) or not interaction_owner.is_inside_tree():
			finish_interaction(interaction_owner, false)
		else:
			velocity = Vector2.ZERO
			_jump_buffer_left = 0.0
			_coyote_left = 0.0
			_play_motion_animation(animation_override)
			if animation_override == &"connect_power":
				_action_left = maxf(0.0, _action_left - delta)
				if _action_left <= 0.0:
					# A stopped/looping clip cannot permanently retain the controls.
					finish_interaction(interaction_owner, true)
			return
	super._physics_process(delta)

## Inicia o salto com os valores de movimento configurados e atualiza o estado de animação.
func _start_jump() -> void:
	super._start_jump()
	_jump_start_left = get_animation_duration(&"jump_start")

## Seleciona a animação apropriada ao movimento, postura ou interação atual.
func _update_animation() -> void:
	if movement_locked and animation_override != &"":
		_play_motion_animation(animation_override)
	elif not is_on_floor() or velocity.y < -1.0:
		_play_motion_animation((&"jump_start" if _jump_start_left > 0.0 else &"jump") if velocity.y < -1.0 else &"fall")
	elif absf(velocity.x) > 8.0:
		_play_motion_animation(&"walk")
	elif _landing_left > 0.0:
		_play_motion_animation(&"land")
	else:
		_play_motion_animation(&"idle")

## Adquire o bloqueio local de movimento para um proprietário e clipe de interação válidos.
func begin_interaction(owner: Node, clip: StringName) -> bool:
	if movement_locked or is_instance_valid(interaction_owner) or not is_on_floor():
		return false
	if not is_instance_valid(owner) or clip not in [&"terminal", &"connect_power"]:
		return false
	var capability: StringName = &"terminal" if clip == &"terminal" else &"energy"
	if not has_ability(capability) or not animated_sprite.sprite_frames.has_animation(clip):
		return false
	interaction_owner = owner
	movement_locked = true
	animation_override = clip
	_action_left = get_animation_duration(clip) + 0.2
	velocity = Vector2.ZERO
	_jump_start_left = 0.0
	_jump_buffer_left = 0.0
	_coyote_left = 0.0
	animated_sprite.play(clip)
	animated_sprite.set_frame_and_progress(0, 0.0)
	return true

## Finaliza a ação do proprietário e devolve o controle, comunicando sucesso ou cancelamento.
func finish_interaction(owner: Node, completed: bool) -> void:
	if owner != interaction_owner:
		return
	var previous := interaction_owner
	interaction_owner = null
	movement_locked = false
	animation_override = &""
	_action_left = 0.0
	_jump_buffer_left = 0.0
	_coyote_left = 0.0
	_landing_left = 0.0
	velocity = Vector2.ZERO
	_play_motion_animation(&"idle")
	if is_instance_valid(previous) and previous.has_method("action_finished"):
		previous.call("action_finished", self, completed)

## Recebe o fim do clipe e libera ou avança o estado temporário correspondente. Contexto: ações locais de terminal e energia de BMO.
func _on_animation_finished() -> void:
	super._on_animation_finished()
	if movement_locked and animation_override == &"connect_power" and animated_sprite.animation == &"connect_power":
		finish_interaction(interaction_owner, true)

## Limpa estados temporários após recuperação, sem reaproveitar uma ação interrompida.
func reset_after_recovery() -> void:
	finish_interaction(interaction_owner, false)
	_jump_start_left = 0.0
	_interaction_left = 0.0
	_landing_left = 0.0
	_jump_buffer_left = 0.0
	_coyote_left = 0.0
	velocity = Vector2.ZERO
	movement_locked = false
	animation_override = &""
	_play_motion_animation(&"idle")
