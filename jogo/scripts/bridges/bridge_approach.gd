extends RefCounted
## A requested, short walk to a fixed formation point. Does not move across voids or bodies.
var anchor: Node2D
var actor: CoopPlayer
var target_x:=0.0
var old_mask:=1
var active:=false
var blocked_reason:=""
var requested_frame:=0

## Inicializa dados locais antes da entrada na árvore. Contexto: aproximação assistida segura até uma âncora.
func _init(node: Node2D) -> void:
	anchor=node
	anchor.add_to_group("bridge_anchors")

## Consulta o trajeto até a formação e retorna o motivo que impede a aproximação, ou texto vazio.
func path_reason(candidate: CoopPlayer,formation: Vector2,radius: float) -> String:
	if not is_instance_valid(candidate) or candidate.movement_locked or not candidate.is_on_floor(): return ""
	if absf(candidate.global_position.x-formation.x)>radius or absf(candidate.global_position.y-formation.y)>12: return ""
	for other in anchor.get_tree().get_nodes_in_group("players"):
		if other==candidate: continue
		var before:=absf(candidate.global_position.x-other.global_position.x)
		var after:=absf(formation.x-other.global_position.x)
		if after>candidate.max_partner_distance and after>before: return "Aproxime a dupla."
	var shape:=candidate.get_node("CollisionShape2D") as CollisionShape2D
	var foot:=shape.global_position.y+(shape.shape as RectangleShape2D).size.y*absf(shape.global_scale.y)*0.5
	var space:=anchor.get_world_2d().direct_space_state
	var steps:=maxi(1,ceili(absf(formation.x-candidate.global_position.x)/6.0))
	for i in range(steps+1):
		var x:=lerpf(candidate.global_position.x,formation.x,float(i)/steps)
		var ray:=PhysicsRayQueryParameters2D.create(Vector2(x,foot-2),Vector2(x,foot+4),1)
		ray.exclude=[candidate.get_rid()]
		var hit:=space.intersect_ray(ray)
		if hit.is_empty() or hit.normal.y> -0.7: return "Aproxime-se pelo chão."
	var original_mask:=candidate.collision_mask
	candidate.collision_mask=3
	var blocked:=absf(formation.x-candidate.global_position.x)>0.45 and candidate.test_move(candidate.global_transform,Vector2(formation.x-candidate.global_position.x,0))
	candidate.collision_mask=original_mask
	if blocked: return "Deixe o caminho até a marca livre."
	return "ok"

## Resolve a seleção da âncora candidata, evitando alternância instável entre âncoras próximas.
func selected(candidate: CoopPlayer,formation: Vector2,radius: float) -> bool:
	var best: Node2D=anchor
	var distance:=candidate.global_position.distance_squared_to(formation)
	for other in anchor.get_tree().get_nodes_in_group("bridge_anchors"):
		if other==anchor or not other.has_method("offer_position") or not other.has_method("accepts_actor") or not other.call("accepts_actor",candidate): continue
		if other.process_mode==Node.PROCESS_MODE_DISABLED or not other.is_visible_in_tree() or other.get("state")!=0: continue
		var p: Vector2=other.call("offer_position")
		var other_approach=other.get("approach")
		if other_approach==null or other_approach.path_reason(candidate,p,other.get("offer_radius"))!="ok": continue
		var d:=candidate.global_position.distance_squared_to(p)
		if d<distance-0.01 or (absf(d-distance)<0.01 and String(other.get_path())<String(best.get_path())):
			best=other
			distance=d
	return best==anchor and path_reason(candidate,formation,radius)=="ok"

## Inicia a aproximação solicitada, mantendo uma referência ao personagem que a controla.
func begin(candidate: CoopPlayer,formation: Vector2,radius: float) -> bool:
	if not selected(candidate,formation,radius): return false
	actor=candidate
	target_x=formation.x
	old_mask=actor.collision_mask
	actor.set_meta("bridge_approach_owner",anchor)
	actor.movement_locked=true
	actor.animation_override=&"walk"
	actor.velocity=Vector2.ZERO
	actor.collision_mask=3
	active=true
	requested_frame=Engine.get_physics_frames()
	return true

## Avança a aproximação em passos seguros e informa se continua, terminou ou foi interrompida.
func advance(delta: float,speed: float) -> int:
	# 0 walking; 1 arrived; -1 safely cancelled/blocked.
	if not active or not is_instance_valid(actor):
		cancel()
		return -1
	var jump_pressed:=Input.is_action_just_pressed("p%d_jump"%actor.player_id)
	if not Input.is_action_pressed(actor.get_ability_action()) or jump_pressed:
		var previous:=actor
		cancel()
		if jump_pressed: previous.set("_jump_buffer_left",previous.jump_buffer_time)
		return -1
	var dx:=target_x-actor.global_position.x
	var axis:=Input.get_axis("p%d_left"%actor.player_id,"p%d_right"%actor.player_id)
	var changed:=Input.is_action_just_pressed("p%d_left"%actor.player_id) or Input.is_action_just_pressed("p%d_right"%actor.player_id)
	if Engine.get_physics_frames()>requested_frame+1 and changed and axis*dx< -0.01:
		cancel()
		return -1
	if absf(dx)<0.45:
		cancel()
		return 1
	# Recheck every step, including an approaching partner.
	var goal:=Vector2(target_x,actor.global_position.y)
	var temporary_lock:=actor.movement_locked
	actor.movement_locked=false
	blocked_reason=path_reason(actor,goal,128)
	actor.movement_locked=temporary_lock
	if blocked_reason!="ok":
		cancel()
		return -1
	actor.face_direction(dx)
	actor.velocity=Vector2(signf(dx)*minf(speed,absf(dx)/delta),0)
	actor.move_and_slide()
	if not actor.is_on_floor():
		cancel()
		return -1
	return 0

## Cancela a ação corrente e libera as referências/controles pertencentes a este mecanismo.
func cancel() -> void:
	if is_instance_valid(actor):
		actor.collision_mask=old_mask
		actor.velocity=Vector2.ZERO
		actor.movement_locked=false
		actor.animation_override=&""
		if actor.get_meta("bridge_approach_owner",null)==anchor: actor.remove_meta("bridge_approach_owner")
	active=false
	actor=null
