extends Node2D
## Reusable state driver. Call update_motion after moving your player body.
signal action_completed(action: StringName)

const CHARACTERS := [&"finn", &"jake", &"fionna", &"cake", &"marceline", &"bmo"]
const PRIMARY := {&"finn": &"push", &"jake": &"bridge_extend", &"fionna": &"crank", &"cake": &"crawl", &"marceline": &"float", &"bmo": &"terminal"}
const SECONDARY := {&"finn": &"pull_lever", &"jake": &"interact", &"fionna": &"push", &"cake": &"stretch", &"marceline": &"play_music", &"bmo": &"connect_power"}

@export var character_id: StringName = &"finn"
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var action: StringName = &""
var ability_held := false
var action_time := 0.0
var action_limit := 0.0
var hold_time := 0.0
var was_grounded := false
var landing_time := 0.0
var last_velocity := Vector2.ZERO
var last_grounded := true
var animation_starts := 0
var loops_seen := 0

## Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: prévia reutilizável de animações dos assets.
func _ready() -> void:
	sprite.animation_finished.connect(_finished)
	sprite.animation_looped.connect(func() -> void: loops_seen += 1)
	set_character(character_id)

## Seleciona os SpriteFrames do personagem válido e reinicia sua apresentação visual.
func set_character(id: StringName) -> void:
	if not CHARACTERS.has(id):
		return
	character_id = id
	if not is_instance_valid(sprite):
		return
	sprite.sprite_frames = load("res://Assets/01_Characters/" + String(id) + "/animations.tres")
	sprite.position = Vector2(0, -32)
	clear_action()
	was_grounded = false
	landing_time = 0.0
	_start(&"idle", true)

## Inicia um clipe existente sem reiniciar a reprodução se ela já estiver correta.
func _start(state: StringName, force: bool = false) -> void:
	if not sprite.sprite_frames.has_animation(state):
		return
	# Repeated movement updates must never reset a running or held state.
	if sprite.animation == state and not force:
		return
	sprite.speed_scale = 1.0
	sprite.play(state)
	if force:
		sprite.set_frame_and_progress(0, 0.0)
	animation_starts += 1

## Limpa a ação temporária e seus temporizadores.
func clear_action() -> void:
	action = &""
	action_time = 0.0
	action_limit = 0.0
	hold_time = 0.0

## Informa se a ação visual atual exige bloqueio de movimento.
func is_movement_locked() -> bool:
	return action != &"" and action not in [&"push", &"crawl", &"float"]

## Sincroniza o estado visual da habilidade pressionada, incluindo sustentação e retração.
func set_ability(held: bool) -> void:
	if held == ability_held:
		return
	ability_held = held
	if held:
		play_action(PRIMARY[character_id], true)
	elif action in [&"bridge_extend", &"bridge_hold"]:
		play_action(&"bridge_retract")
	elif action in [&"push", &"crawl", &"float", &"terminal"]:
		clear_action()

## Reproduz a ação secundária correspondente à identidade configurada.
func play_secondary() -> void:
	play_action(SECONDARY[character_id])

## Inicia uma ação existente e configura o prazo de recuperação de seu clipe.
func play_action(state: StringName, held: bool = false) -> void:
	if not sprite.sprite_frames.has_animation(state):
		return
	action = state
	action_time = 0.0
	var frames := sprite.sprite_frames
	var units := 0.0
	for i in range(frames.get_frame_count(state)):
		units += frames.get_frame_duration(state, i)
	var duration := units / maxf(1.0, frames.get_animation_speed(state))
	action_limit = -1.0 if held else maxf(0.7, duration + 0.12)
	_start(state, true)

## Escolhe locomoção, aterrissagem ou ação a partir de velocidade, apoio e tempo decorrido.
func update_motion(velocity: Vector2, grounded: bool, delta: float) -> void:
	last_velocity = velocity
	last_grounded = grounded
	if absf(velocity.x) > 1.0:
		sprite.flip_h = velocity.x < 0.0
	if grounded and not was_grounded and velocity.y >= -1.0 and action == &"":
		landing_time = 0.10
		_start(&"land", true)
	was_grounded = grounded
	if action != &"":
		action_time += delta
		if action in [&"bridge_hold", &"stretch_hold"] and not ability_held:
			hold_time += delta
			if hold_time > 0.35:
				play_action(&"bridge_retract" if action == &"bridge_hold" else &"stretch_retract")
		if action_limit > 0.0 and action_time > action_limit:
			clear_action()
		if action != &"":
			return
	landing_time = maxf(0.0, landing_time - delta)
	if not grounded:
		landing_time = 0.0
		_start(&"jump" if velocity.y < -12.0 else &"fall")
	elif landing_time > 0.0:
		return
	elif absf(velocity.x) > 5.0:
		_start(&"walk")
		sprite.speed_scale = clampf(absf(velocity.x) / 100.0, 0.65, 1.35)
	else:
		_start(&"idle")

## Converte extensão em sustentação ou encerra a ação e emite sua conclusão.
func _finished() -> void:
	var ended := sprite.animation
	if ended != action:
		return
	if action == &"bridge_extend":
		action = &"bridge_hold"
		action_time = 0.0
		action_limit = -1.0
		hold_time = 0.0
		_start(&"bridge_hold")
	elif action == &"stretch":
		action = &"stretch_hold"
		action_time = 0.0
		action_limit = -1.0
		hold_time = 0.0
		_start(&"stretch_hold")
	else:
		clear_action()
		action_completed.emit(ended)
		# The next motion update chooses idle/walk/jump/fall without replaying an action.
