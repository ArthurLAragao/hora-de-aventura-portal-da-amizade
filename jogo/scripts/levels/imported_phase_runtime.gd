extends Node2D
## Small integration hooks for received levels; no terrain or puzzle design changes.
var completion_count := 0

## Conecta a cena recebida aos controles, conclusão, recuperação e interface existentes.
func configure_imported_phase() -> void:
	$FallZone.recovery_started.connect(_cancel_local_actions)
	$CooperativeExit.level_completed.connect(_on_imported_completion)
	_configure_respawn_markers.call_deferred()

## Cancela interações locais antes de recuperar ou reiniciar a dupla.
func _cancel_local_actions() -> void:
	for actor in $Players.get_children():
		if actor.has_method("reset_after_recovery"):
			actor.reset_after_recovery()
		elif actor is CoopPlayer:
			actor.velocity = Vector2.ZERO
			actor.animation_override = &""
			actor.movement_locked = false
			actor._interaction_left = 0.0
			actor._jump_buffer_left = 0.0
			actor._coyote_left = 0.0

## Recebe a conclusão da fase integrada e atualiza o encerramento disponível.
func _on_imported_completion() -> void:
	completion_count += 1
	_cancel_local_actions()
	for actor in $Players.get_children():
		if actor is CoopPlayer: actor.movement_locked = true

## Trata comandos contextuais de teclado não consumidos pela interface. Contexto: integração comum das fases 3 e 4.
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F2:
		_cancel_local_actions()
		get_viewport().set_input_as_handled()
		get_tree().reload_current_scene()

## Configura marcadores de retorno para os dois personagens ativos.
func _configure_respawn_markers() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	var actors := $Players.get_children()
	var starts: Array[Vector2] = []
	var markers := [$Checkpoint/FinnSpawn, $Checkpoint/JakeSpawn]
	for i in 2:
		var actor := actors[i] as CoopPlayer
		starts.append(to_local(_grounded_destination(actor, actor.global_position)))
		markers[i].global_position = _grounded_destination(actor, markers[i].global_position)
	$FallZone.starting_positions = starts

## Calcula um destino cujo colisor se apoia na superfície consultada.
func _grounded_destination(actor: CoopPlayer, desired: Vector2) -> Vector2:
	# The received spawn centers are high above the floor. Ground recovery markers
	# against the existing collision; do not move initial actors, tiles or scenery.
	var query := PhysicsRayQueryParameters2D.create(desired, desired + Vector2(0, 256), 1)
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if hit.is_empty(): return desired
	var collider := actor.get_node("CollisionShape2D") as CollisionShape2D
	var shape := collider.shape as RectangleShape2D
	var bottom := collider.global_transform * Vector2(0, shape.size.y * 0.5)
	var bottom_offset := bottom.y - actor.global_position.y
	return Vector2(desired.x, hit.position.y - bottom_offset - 2.5)
