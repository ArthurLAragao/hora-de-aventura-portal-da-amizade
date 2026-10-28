extends "res://scripts/characters/player.gd"
@export_range(40,140,1) var crawl_speed: float = 100.0
var crawling := false
var crawl_owner: Node
var pose_owner: Node
var _needed_low := false
var _jump_start_left := 0.0
@onready var body: CollisionShape2D = $CollisionShape2D
var _normal_shape: RectangleShape2D
var _low_shape: RectangleShape2D

## Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: rastejo e postura de Cake.
func _ready() -> void:
	super._ready()
	_normal_shape = body.shape.duplicate() as RectangleShape2D
	_low_shape = RectangleShape2D.new()
	_low_shape.size = Vector2(38,21)
	body.shape = _normal_shape

## Atualiza a lógica em passos fixos de física; delta representa segundos. Contexto: rastejo e postura de Cake.
func _physics_process(delta: float) -> void:
	_jump_start_left = maxf(0,_jump_start_left-delta)
	if is_instance_valid(pose_owner):
		velocity = Vector2.ZERO
		_jump_buffer_left = 0
		_coyote_left = 0
		_play_motion_animation(animation_override)
		return
	if movement_locked and (has_meta("bridge_approach_owner") or get_meta("pair_handoff_lock",false)):
		super._physics_process(delta)
		return
	if movement_locked:
		movement_locked = false
		animation_override = &""
	if crawling:
		if not can_stand(): _needed_low = true
		if _needed_low and can_stand(): request_stand()
	var normal_speed := speed
	if crawling: speed = crawl_speed
	super._physics_process(delta)
	speed = normal_speed

## Consulta a geometria acima de Cake antes de restaurar o colisor alto.
func can_stand() -> bool:
	# Leave 0.2 units of floor clearance in the probe; never shift the feet.
	var probe := RectangleShape2D.new()
	probe.size = Vector2(30,27.8)
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = probe
	query.transform = global_transform * Transform2D(0,Vector2(0,17.9))
	query.collision_mask = 1
	query.exclude = [get_rid()]
	return get_world_2d().direct_space_state.intersect_shape(query,1).is_empty()

## Entra na postura baixa autorizada pelo túnel, mantendo o deslocamento controlável.
func begin_crawl(owner: Node) -> bool:
	if not has_ability(&"crawl") or crawling or movement_locked or not is_on_floor(): return false
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = _low_shape
	query.transform = global_transform * Transform2D(0,Vector2(0,21.5))
	query.collision_mask = 1
	query.exclude = [get_rid()]
	if not get_world_2d().direct_space_state.intersect_shape(query,1).is_empty(): return false
	crawling = true
	crawl_owner = owner
	_needed_low = false
	body.shape = _low_shape
	body.position = Vector2(0,21.5)
	_jump_buffer_left = 0
	_coyote_left = 0
	_play_motion_animation(&"crawl")
	return true

## Tenta restaurar a postura normal somente se houver espaço livre acima.
func request_stand() -> bool:
	if not crawling: return true
	if not can_stand(): return false
	crawling = false
	crawl_owner = null
	_needed_low = false
	body.shape = _normal_shape
	body.position = Vector2(0,18)
	_jump_buffer_left = 0
	_coyote_left = 0
	_update_animation()
	return true

## Inicia o salto com os valores de movimento configurados e atualiza o estado de animação.
func _start_jump() -> void:
	if crawling:
		_jump_buffer_left = 0
		return
	super._start_jump()
	_jump_start_left = get_animation_duration(&"jump_start")

## Seleciona a animação apropriada ao movimento, postura ou interação atual.
func _update_animation() -> void:
	if movement_locked and animation_override != &"": _play_motion_animation(animation_override)
	elif crawling: _play_motion_animation(&"crawl")
	elif not is_on_floor() or velocity.y < -1:
		_play_motion_animation((&"jump_start" if _jump_start_left>0 else &"jump") if velocity.y< -1 else &"fall")
	elif absf(velocity.x)>8: _play_motion_animation(&"walk")
	elif _landing_left>0: _play_motion_animation(&"land")
	else: _play_motion_animation(&"idle")

## Finaliza a pose temporária e devolve a personagem à animação de movimento.
func finish_pose() -> void:
	pose_owner = null
	movement_locked = false
	animation_override = &""
	velocity = Vector2.ZERO
	_jump_buffer_left = 0
	_coyote_left = 0
	animated_sprite.show()
	_update_animation()

## Limpa estados temporários após recuperação, sem reaproveitar uma ação interrompida.
func reset_after_recovery() -> void:
	if has_meta("pair_handoff_lock"): remove_meta("pair_handoff_lock")
	var approach_owner=get_meta("bridge_approach_owner") if has_meta("bridge_approach_owner") else null
	if is_instance_valid(approach_owner) and approach_owner.has_method("cancel_immediately"): approach_owner.call("cancel_immediately",true)
	if is_instance_valid(pose_owner): pose_owner.call("cancel_immediately",true)
	finish_pose()
	# Called at the current position: still never stand into a roof.
	request_stand()
	_jump_start_left = 0
	_landing_left = 0
	_interaction_left = 0
