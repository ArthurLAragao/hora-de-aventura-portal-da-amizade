extends Area2D
class_name CoopFallZone

@export var finn_path: NodePath
@export var jake_path: NodePath
@export var starting_positions: Array[Vector2] = [Vector2(256.0, 245.0), Vector2(300.0, 245.0)]
@export var checkpoint_path: NodePath
@export var bridge_path: NodePath = NodePath("../JakeBridge")
@export var trunk_puzzle_path: NodePath = NodePath("../TrunkPuzzle")

var finn: CoopPlayer
var jake: CoopPlayer
var checkpoint: CoopCheckpoint
var bridge: JakeBridge

signal recovery_started
signal recovery_finished(used_checkpoint: bool)
var recovery_count := 0

var _respawning := false
var _used_checkpoint := false
var _relocated_obstacles: Array[RID] = []

## Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: recuperação conjunta após queda.
func _ready() -> void:
	finn = get_node_or_null(finn_path) as CoopPlayer
	jake = get_node_or_null(jake_path) as CoopPlayer
	checkpoint = get_node_or_null(checkpoint_path) as CoopCheckpoint
	bridge = get_node_or_null(bridge_path) as JakeBridge
	body_entered.connect(_on_body_entered)

## Registra a entrada de um corpo elegível na área e reavalia a ação local. Contexto: recuperação conjunta após queda.
func _on_body_entered(body: Node2D) -> void:
	if _respawning or (body != finn and body != jake) or not overlaps_body(body):
		return
	_respawning = true
	if is_instance_valid(checkpoint):
		checkpoint.set_recovery_in_progress(true)
	recovery_started.emit()
	call_deferred("_respawn_both")

## Seleciona destinos seguros e inicia uma única recuperação para a dupla.
func _respawn_both() -> void:
	if not _respawning:
		return
	_relocated_obstacles.clear()
	# Reuse the bridge's one restoration path, including its sprite/signal cleanup.
	# Both players are moved in this same deferred call, so no stranded rider remains.
	if is_instance_valid(bridge):
		bridge._finish_retraction()
	# A log restored during this call is an AnimatableBody2D. Keep the pair
	# still until physics has consumed that relocation, so old platform motion
	# cannot carry a respawned character away from the safe markers.
	if is_instance_valid(finn): finn.movement_locked = true
	if is_instance_valid(jake): jake.movement_locked = true
	var destinations: Array[Vector2] = []
	_used_checkpoint = is_instance_valid(checkpoint) and checkpoint.activated
	if _used_checkpoint:
		destinations = checkpoint.get_respawn_positions()
	if destinations.size() != 2:
		_used_checkpoint = false
		destinations = _starting_world_positions()
	_restore_obstructing_unsolved_log(destinations)
	destinations = _safe_pair_near(destinations)
	if destinations.is_empty() and _used_checkpoint:
		_used_checkpoint = false
		destinations = _safe_pair_near(_starting_world_positions())
	if destinations.size() == 2 and is_instance_valid(finn) and is_instance_valid(jake):
		finn.global_position = destinations[0]
		jake.global_position = destinations[1]
		finn.velocity = Vector2.ZERO
		jake.velocity = Vector2.ZERO
	else:
		push_error("Recovery has no safe pair of positions; no unsafe teleport performed.")
	# Hold the guard through physics overlap updates. Two near-simultaneous falls
	# must not enqueue a second recovery or activate a checkpoint during return.
	await get_tree().physics_frame
	await get_tree().physics_frame
	_complete_recovery.call_deferred()

## Conclui a recuperação e libera a trava contra chamadas duplicadas.
func _complete_recovery() -> void:
	for player in [finn, jake]:
		if is_instance_valid(player):
			player.velocity = Vector2.ZERO
			player.movement_locked = false
	if is_instance_valid(checkpoint):
		checkpoint.set_recovery_in_progress(false)
	recovery_count += 1
	_respawning = false
	recovery_finished.emit(_used_checkpoint)

## Converte as posições iniciais configuradas em destinos no mundo.
func _starting_world_positions() -> Array[Vector2]:
	var result: Array[Vector2] = []
	var level := get_parent() as Node2D
	for point in starting_positions:
		result.append(level.to_global(point) if level != null else point)
	return result

## Calcula o retângulo físico do corpo na posição consultada.
func _body_rect(body: Node2D, destination: Vector2) -> Rect2:
	var collider := body.get_node("CollisionShape2D") as CollisionShape2D
	var shape := collider.shape as RectangleShape2D
	var transform := collider.global_transform
	transform.origin += destination - body.global_position
	var first := transform * (-shape.size * 0.5)
	var last := transform * (shape.size * 0.5)
	return Rect2(first, last - first).abs()

## Consulta apoio físico abaixo de uma posição candidata.
func _has_floor(body: Node2D, rectangle: Rect2) -> bool:
	var space := get_world_2d().direct_space_state
	for x in [rectangle.position.x + 2.0, rectangle.get_center().x, rectangle.end.x - 2.0]:
		var start := Vector2(x, rectangle.end.y + 0.1)
		var ray := PhysicsRayQueryParameters2D.create(start, start + Vector2(0, 24), 1)
		ray.exclude = [body.get_rid()]
		if space.intersect_ray(ray).is_empty():
			return false
	return true

## Avalia um destino com espaço livre e chão seguro.
func _safe_position(player: CoopPlayer, destination: Vector2) -> bool:
	var collider := player.get_node("CollisionShape2D") as CollisionShape2D
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = collider.shape
	query.transform = collider.global_transform
	query.transform.origin += destination - player.global_position
	query.collision_mask = 1
	# A reset performed in this deferred call can still have its old broadphase
	# position until the next physics tick. Its new safe location is not a blocker.
	var excluded: Array[RID] = [player.get_rid()]
	excluded.append_array(_relocated_obstacles)
	query.exclude = excluded
	return get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty() and _has_floor(player, _body_rect(player, destination))

## Procura dois destinos separados e seguros próximos da referência.
func _safe_pair_near(preferred: Array[Vector2]) -> Array[Vector2]:
	if preferred.size() != 2 or not is_instance_valid(finn) or not is_instance_valid(jake):
		return []
	# A small local fallback only when a moved object obstructs the markers.
	# Both keep their separate spots and remain on the same side of the puzzles.
	for offset in [0.0, -32.0, 32.0, -64.0, 64.0]:
		var a := preferred[0] + Vector2(offset, 0)
		var b := preferred[1] + Vector2(offset, 0)
		if _safe_position(finn, a) and _safe_position(jake, b) and not _body_rect(finn, a).grow(4).intersects(_body_rect(jake, b)):
			return [a, b]
	return []

## Restaura o bloco ainda não resolvido quando ele impede uma recuperação segura.
func _restore_obstructing_unsolved_log(destinations: Array[Vector2]) -> void:
	var puzzle := get_node_or_null(trunk_puzzle_path)
	if puzzle == null or destinations.size() != 2:
		return
	var gate := puzzle.get_node_or_null("Gate") as CoopGate
	var log := puzzle.get_node_or_null("Log") as PushBlock
	if gate == null or log == null or gate.is_open:
		return
	var rectangle := _body_rect(log, log.global_position)
	var obstructs := rectangle.grow(2).intersects(_body_rect(finn, destinations[0])) or rectangle.grow(2).intersects(_body_rect(jake, destinations[1]))
	if obstructs or not _has_floor(log, rectangle):
		log.reset_to_start()
		_relocated_obstacles.append(log.get_rid())
