extends AnimatableBody2D
## A short horizontal extension. Always visible/collidable; docked in the bank.
@export var extension := Vector2(-96,0)
@export_range(20,200,1) var travel_speed: float = 120.0
var requested := false
var extended := false
var blocked := false
var _start := Vector2.ZERO
var _target := Vector2.ZERO
@onready var body_shape: CollisionShape2D = $CollisionShape2D

## Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: extensão permanente da plataforma.
func _ready() -> void:
	sync_to_physics = false
	_start = position
	_target = _start + extension

## Solicita a extensão permanente até o destino configurado.
func extend_passage() -> void:
	requested = true

## Atualiza a lógica em passos fixos de física; delta representa segundos. Contexto: extensão permanente da plataforma.
func _physics_process(delta: float) -> void:
	if not requested or extended: return
	var next := position.move_toward(_target,travel_speed*delta)
	var motion := next-position
	# Check the full swept step, with a little clearance above the support.
	# Characters retain control; the platform waits instead of moving them.
	var sweep := RectangleShape2D.new()
	sweep.size = Vector2(58+absf(motion.x)+2,14)
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = sweep
	query.transform = global_transform * Transform2D(0,Vector2(motion.x*0.5,5))
	query.collision_mask = 2
	query.exclude = [get_rid()]
	blocked = not get_world_2d().direct_space_state.intersect_shape(query,1).is_empty()
	if blocked: return
	var hit := move_and_collide(motion)
	blocked = hit != null
	if position.distance_to(_target)<0.01:
		extended = true
		blocked = false
