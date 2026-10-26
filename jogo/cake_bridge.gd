extends Area2D
## Local Cake composition; uses the proven render/hold/dependency pattern, without touching Jake.
enum State { IDLE, EXTENDING, HOLDING, RETRACTING }
enum Step { NONE, SOURCE, GROW, WAIT_RENDER, FULL, SHRINK, REVERSE }
@export_range(2,12,1) var activation_half_width := 8.0
@export_range(0.2,2,0.05) var growth_duration := 0.75
@export_range(0.2,2,0.05) var shrink_duration := 0.75
var state := State.IDLE
var step := Step.NONE
var owner_actor: CoopPlayer
var release_pending := false
var _elapsed := 0.0
var _timeout := 0.0
var _progress := 0.0
var _clear_ticks := 0
var _support_active := false
var _locked_origin := Vector2.ZERO
var visual: Node2D
var support: StaticBody2D
@onready var prompt: Label = $Prompt

func _ready() -> void:
	visual=Node2D.new()
	visual.set_script(load("res://cake_bridge_visual.gd"))
	visual.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(visual)
	visual.hide()
	support=StaticBody2D.new()
	support.collision_layer=0
	support.collision_mask=0
	add_child(support)
	var shape:=CollisionPolygon2D.new()
	shape.polygon=PackedVector2Array([Vector2(-13,20),Vector2(99,20),Vector2(99,18),Vector2(100,16),Vector2(102,16),Vector2(103,17),Vector2(106,17),Vector2(107,16),Vector2(108,16),Vector2(109,19),Vector2(110,20),Vector2(111,21),Vector2(112,22),Vector2(112,32),Vector2(-13,32)])
	support.add_child(shape)

func can_activate(actor: CoopPlayer) -> bool:
	if not is_instance_valid(actor) or not actor.has_ability(&"stretch") or not actor.has_method("finish_pose") or actor.get("crawling") or actor.movement_locked or not actor.is_on_floor() or not overlaps_body(actor): return false
	var p:=to_local(actor.global_position)
	var relative:=global_transform.affine_inverse()*actor.global_transform
	return absf(p.x)<=activation_half_width and absf(p.y)<=4 and relative.x.is_equal_approx(Vector2.RIGHT) and relative.y.is_equal_approx(Vector2.DOWN)

func activate(actor: CoopPlayer) -> bool:
	if state!=State.IDLE or not can_activate(actor): return false
	for clip in [&"stretch",&"stretch_hold",&"stretch_retract"]:
		if not actor.animated_sprite.sprite_frames.has_animation(clip): return false
	owner_actor=actor
	_locked_origin=to_local(actor.global_position)
	actor.set("pose_owner",self)
	actor.movement_locked=true
	actor.velocity=Vector2.ZERO
	actor.face_direction(1)
	visual.position=_locked_origin
	support.position=_locked_origin
	visual.set("frame",actor.animated_sprite.sprite_frames.get_frame_texture(&"stretch_hold",0))
	release_pending=false
	_progress=0
	_clear_ticks=0
	state=State.EXTENDING
	step=Step.SOURCE
	_play(false,false)
	return true

func _play(reverse: bool, keep_frame: bool) -> void:
	_elapsed=0
	_timeout=clampf(owner_actor.get_animation_duration(&"stretch")+0.12,0.15,1.2)
	var old_frame:=owner_actor.animated_sprite.frame
	owner_actor.animation_override=&"stretch"
	if reverse: owner_actor.animated_sprite.play_backwards(&"stretch")
	else: owner_actor.animated_sprite.play(&"stretch")
	owner_actor.animated_sprite.set_frame_and_progress(old_frame if keep_frame else (2 if reverse else 0),0)

func _physics_process(delta: float) -> void:
	if state==State.IDLE: return
	if not is_instance_valid(owner_actor):
		cancel_immediately(true)
		return
	_elapsed+=delta
	if not Input.is_action_pressed(owner_actor.get_ability_action()): release_pending=true
	match step:
		Step.SOURCE:
			if release_pending: _reverse_source(true)
			elif _elapsed>=_timeout:
				step=Step.GROW
				owner_actor.animated_sprite.hide()
				visual.call("set_progress",0)
				visual.show()
		Step.GROW:
			if release_pending: _shrink()
			else:
				_progress=minf(1,_progress+delta/growth_duration)
				visual.call("set_progress",smoothstep(0,1,_progress))
				if _progress>=1:
					step=Step.WAIT_RENDER
					_elapsed=0
		Step.WAIT_RENDER:
			if release_pending: _shrink()
			elif visual.call("has_full_render"):
				_support_active=true
				support.collision_layer=1
				state=State.HOLDING
				step=Step.FULL
			elif _elapsed>1: _shrink()
		Step.FULL:
			if release_pending:
				_clear_ticks=_clear_ticks+1 if get_dependents().is_empty() else 0
				if _clear_ticks>=2: _shrink()
		Step.SHRINK:
			_progress=maxf(0,_progress-delta/shrink_duration)
			visual.call("set_progress",smoothstep(0,1,_progress))
			if _progress<=0: _reverse_source(false)
		Step.REVERSE:
			if _elapsed>=_timeout: cancel_immediately(true)

func _shrink() -> void:
	_support_active=false
	support.collision_layer=0
	state=State.RETRACTING
	step=Step.SHRINK

func _reverse_source(keep: bool) -> void:
	_support_active=false
	support.collision_layer=0
	visual.hide()
	owner_actor.animated_sprite.show()
	state=State.RETRACTING
	step=Step.REVERSE
	_play(true,keep)

func get_dependents() -> Array[CoopPlayer]:
	var result: Array[CoopPlayer]=[]
	for actor in get_tree().get_nodes_in_group("players"):
		if actor==owner_actor or not actor is CoopPlayer: continue
		var collider:=actor.get_node("CollisionShape2D") as CollisionShape2D
		if not collider.shape is RectangleShape2D: continue
		var size: Vector2=collider.shape.size
		var box:=Rect2(to_local(collider.global_position)-size*0.5,size)
		if actor.is_on_floor() and actor.velocity.y>=0 and box.end.y>_locked_origin.y+23: continue
		var predicted:=Rect2(box.position+global_transform.basis_xform_inv(actor.velocity)*0.12,box.size)
		var swept:=box.merge(predicted)
		if swept.end.x>_locked_origin.x-13 and swept.position.x<_locked_origin.x+112 and box.position.y<_locked_origin.y+34: result.append(actor)
	return result

func cancel_immediately(force: bool=false) -> void:
	if not force and _support_active and not get_dependents().is_empty():
		release_pending=true
		return
	if is_instance_valid(support): support.collision_layer=0
	if is_instance_valid(visual): visual.hide()
	if is_instance_valid(owner_actor): owner_actor.call("finish_pose")
	owner_actor=null
	_support_active=false
	state=State.IDLE
	step=Step.NONE
	release_pending=false
	_progress=0

func update_prompt(actor: CoopPlayer) -> void:
	if state!=State.IDLE: prompt.text="Aguardando a parceira sair com segurança." if release_pending and _support_active else "Ponte de Cake — solte para recolher."
	elif can_activate(actor): prompt.text=("Q" if actor.player_id==1 else "Shift direito")+": formar ponte"
	else: prompt.text="Cake: aproxime-se da marca no chão."

func _exit_tree() -> void:
	if is_instance_valid(owner_actor): owner_actor.call("finish_pose")
