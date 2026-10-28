extends Camera2D
class_name SharedCamera

@export var player_a_path: NodePath
@export var player_b_path: NodePath
@export var follow_smoothing: float = 6.0
@export var world_left: float = 0.0
@export var world_right: float = 2304.0
@export var world_top: float = 0.0
@export var world_bottom: float = 640.0
@export var max_separation: float = 680.0

var _separation_warning_active := false
var player_a: Node2D
var player_b: Node2D

## Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: câmera compartilhada e limites do cenário.
func _ready() -> void:
	player_a = get_node_or_null(player_a_path) as Node2D
	player_b = get_node_or_null(player_b_path) as Node2D
	position_smoothing_enabled = true
	position_smoothing_speed = follow_smoothing
	limit_left = roundi(world_left)
	limit_right = roundi(world_right)
	limit_top = roundi(world_top)
	limit_bottom = roundi(world_bottom)
	make_current()

## Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: câmera compartilhada e limites do cenário.
func _process(_delta: float) -> void:
	if not is_instance_valid(player_a) or not is_instance_valid(player_b):
		return
	var midpoint := (player_a.global_position + player_b.global_position) * 0.5
	global_position = Vector2(clampf(midpoint.x, world_left, world_right), clampf(midpoint.y, world_top, world_bottom))
	var is_too_far := player_a.global_position.distance_to(player_b.global_position) > max_separation
	if is_too_far and not _separation_warning_active:
		var hud := get_parent().get_node_or_null("HUD")
		if hud is PhaseHud:
			(hud as PhaseHud).show_message("Fiquem pertinho um do outro!", 2.0)
	_separation_warning_active = is_too_far
