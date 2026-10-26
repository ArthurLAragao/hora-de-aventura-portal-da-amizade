extends Area2D
signal activated
@export var platform_path: NodePath
var operator: CoopPlayer
var pending := false
var solved := false
var activation_count := 0
@onready var prompt: Label = $Prompt
@onready var status: Label = $Status
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func can_interact(actor: CoopPlayer) -> bool:
	return is_instance_valid(actor) and actor.has_ability(&"crank") and actor.has_method("begin_crank") and overlaps_body(actor) and actor.is_on_floor() and not actor.movement_locked and not pending and not solved and get_node_or_null(platform_path)!=null

func interact(actor: CoopPlayer) -> bool:
	if not can_interact(actor): return false
	if not actor.call("begin_crank",self):
		status.text = "Animação indisponível; controles livres."
		return false
	operator = actor
	actor.face_direction(global_position.x-actor.global_position.x)
	pending = true
	sprite.play(&"crank_45")
	status.text = "Girando… Esc cancela"
	return true

func action_finished(_actor: CoopPlayer, completed: bool) -> void:
	if not pending: return
	pending = false
	operator = null
	var platform := get_node_or_null(platform_path)
	if completed and not solved and platform != null:
		solved = true
		activation_count += 1
		sprite.play(&"crank_90")
		platform.call("extend_passage")
		status.text = "✓ Manivela acionada"
		activated.emit()
	else:
		sprite.play(&"crank_0")
		status.text = "Ação interrompida; tente novamente."

func cancel() -> void:
	if is_instance_valid(operator): operator.call("finish_crank",self,false)
	else: action_finished(null,false)

func _physics_process(_delta: float) -> void:
	if pending and (not is_instance_valid(operator) or not overlaps_body(operator) or not is_instance_valid(get_node_or_null(platform_path))): cancel()

func update_prompt(actor: CoopPlayer) -> void:
	prompt.text = ""
	if can_interact(actor): prompt.text = ("E" if actor.player_id==1 else "Enter")+": manivela"
	elif not pending and not solved and get_overlapping_bodies().size()>0: prompt.text = "Requer capacidade: manivela"
	if solved:
		var platform := get_node_or_null(platform_path)
		if platform != null:
			status.text = "✓ Passagem estendida" if platform.get("extended") else ("Aguardando: libere a trajetória." if platform.get("blocked") else "Estendendo passagem…")

func _exit_tree() -> void:
	if is_instance_valid(operator) and operator.get("interaction_owner")==self:
		operator.call("finish_crank",self,false)
