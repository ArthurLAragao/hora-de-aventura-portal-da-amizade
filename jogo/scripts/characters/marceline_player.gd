extends "res://scripts/characters/player.gd"
## Shared movement stays in CoopPlayer. Only Marceline's ability/poses live here.

@export_range(0.1, 2.0, 0.05) var float_duration: float = 1.0
@export_range(5.0, 120.0, 1.0) var float_fall_speed: float = 45.0

var is_floating := false
var float_remaining := 0.0
var _jump_start_left := 0.0

## Atualiza a lógica em passos fixos de física; delta representa segundos. Contexto: flutuação limitada e ação musical de Marceline.
func _physics_process(delta: float) -> void:
	_jump_start_left = maxf(0.0, _jump_start_left - delta)
	var grounded := is_on_floor() and velocity.y >= 0.0
	if movement_locked:
		is_floating = false
		float_remaining = 0.0
		_jump_start_left = 0.0
		_interaction_left = 0.0
	else:
		if grounded:
			float_remaining = float_duration
		is_floating = not grounded and has_ability(&"float") and Input.is_action_pressed(get_ability_action()) and float_remaining > 0.0
		if is_floating:
			float_remaining = maxf(0.0, float_remaining - delta)
	super._physics_process(delta)
	if is_on_floor() and velocity.y >= 0.0:
		is_floating = false
		float_remaining = float_duration
	elif float_remaining <= 0.0:
		is_floating = false
	if not movement_locked:
		_update_animation()

## Aplica a aceleração vertical enquanto o personagem está no ar.
func _apply_air_gravity(delta: float) -> void:
	if is_floating and velocity.y >= 0.0:
		velocity.y = minf(velocity.y + gravity * delta, float_fall_speed)
	else:
		# Rising motion is unchanged. Floating never adds upward velocity.
		super._apply_air_gravity(delta)

## Inicia o salto com os valores de movimento configurados e atualiza o estado de animação.
func _start_jump() -> void:
	if is_on_floor():
		float_remaining = float_duration
	super._start_jump()
	is_floating = false
	_jump_start_left = get_animation_duration(&"jump_start")

## Seleciona a animação apropriada ao movimento, postura ou interação atual.
func _update_animation() -> void:
	if _interaction_left > 0.0:
		_play_motion_animation(_interaction_animation)
	elif is_floating:
		_play_motion_animation(&"float")
	elif not is_on_floor() or velocity.y < -1.0:
		if velocity.y < -1.0:
			_play_motion_animation(&"jump_start" if _jump_start_left > 0.0 else &"jump")
		else:
			_play_motion_animation(&"fall")
	elif absf(velocity.x) > 8.0:
		_play_motion_animation(&"walk")
	elif _landing_left > 0.0:
		_play_motion_animation(&"land")
	else:
		_play_motion_animation(&"idle")

## Inicia o clipe musical sem permitir um bloqueio permanente de controles.
func play_music_interaction() -> bool:
	if movement_locked or not has_ability(&"music") or _interaction_left > 0.0:
		return false
	if not animated_sprite.sprite_frames.has_animation(&"play_music"):
		return false
	_interaction_animation = &"play_music"
	_interaction_left = get_animation_duration(&"play_music") + 0.1
	animated_sprite.play(&"play_music")
	animated_sprite.set_frame_and_progress(0, 0.0)
	return true

## Recebe o fim do clipe e libera ou avança o estado temporário correspondente. Contexto: flutuação limitada e ação musical de Marceline.
func _on_animation_finished() -> void:
	super._on_animation_finished()
	if animated_sprite.animation == &"play_music":
		_interaction_left = 0.0

## Limpa estados temporários após recuperação, sem reaproveitar uma ação interrompida.
func reset_after_recovery() -> void:
	is_floating = false
	float_remaining = 0.0
	_jump_start_left = 0.0
	_interaction_left = 0.0
	_landing_left = 0.0
	_jump_buffer_left = 0.0
	_coyote_left = 0.0
	velocity = Vector2.ZERO
	movement_locked = false
	animation_override = &""
	_play_motion_animation(&"idle")
