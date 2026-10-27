extends Node2D
class_name JakeBridge

signal prompt_changed(visible: bool)
enum State { IDLE, EXTENDING, HOLDING, RETRACTING }
enum Step { NONE, SOURCE_EXTEND, GROW, WAIT_RENDER, FULL, SHRINK, SOURCE_RETRACT }

@export var required_ability: StringName = &"bridge"
@export_range(0.05, 0.5, 0.01) var animation_timeout_margin := 0.15
@export_range(0.2, 2.0, 0.05) var growth_duration := 1.0
@export_range(0.2, 2.0, 0.05) var shrink_duration := 1.0
## The valid player ORIGIN band, in this anchor's coordinates, not hitbox overlap.
@export var activation_origin_rect := Rect2(-8, -7.15, 8, 3)
@export_range(0.0, 0.25, 0.01) var dependency_prediction_time := 0.12

@onready var activation_area: Area2D = $ActivationArea
@onready var bridge_body: StaticBody2D = $BridgeBody
@onready var bridge_visual: JakeBridgeVisual = $BridgeVisual
@onready var anchor_visual: Sprite2D = $AnchorSprite
@onready var stretch_sfx: AudioStreamPlayer2D = $StretchSFX
@onready var retract_sfx: AudioStreamPlayer2D = $RetractSFX

@export var formation_offset:=Vector2(-20,-5.65)
@export_range(32,100,1) var offer_radius:=72.0
@export_range(48,140,1) var approach_speed:=96.0
var approach: RefCounted
var approach_actor: CoopPlayer
var approach_hint: Label
var state: State = State.IDLE
var step: Step = Step.NONE
var release_pending := false
var _jake: CoopPlayer
var _bridge_active := false
var _elapsed := 0.0
var _timeout := 0.0
var _progress := 0.0
var _clear_ticks := 0
var _prompt_visible := false
var _cancel_requested:=false
var _sprite_was_visible := true
var _locked_origin := Vector2.ZERO

func _ready() -> void:
	approach=load("res://bridge_approach.gd").new(self)
	$ActivationMarker.position.x=formation_offset.x-9
	$ActivationArea.position=formation_offset
	var offer_shape=$ActivationArea/CollisionShape2D
	offer_shape.shape=offer_shape.shape.duplicate()
	offer_shape.shape.size.x=offer_radius*2
	approach_hint=Label.new()
	approach_hint.position=Vector2(-128,-88)
	approach_hint.add_theme_font_override("font",load("res://Assets/08_Fonts/NotoSans.ttf"))
	approach_hint.add_theme_font_size_override("font_size",14)
	approach_hint.add_theme_color_override("font_outline_color",Color("102832"))
	approach_hint.add_theme_constant_override("outline_size",4)
	add_child(approach_hint)
	_set_support(false)
	bridge_visual.hide()

func _physics_process(delta: float) -> void:
	if approach!=null and approach.active:
		var result: int=approach.advance(delta,approach_speed)
		approach_hint.text="Aproximando... solte para cancelar."
		if result==1 and is_instance_valid(approach_actor): _begin_bridge(approach_actor)
		return
	if state == State.IDLE:
		var candidate := _find_candidate()
		_set_prompt(is_instance_valid(candidate))
		approach_hint.text=""
		if is_instance_valid(candidate):
			approach_hint.text=("Q" if candidate.player_id==1 else "Shift direito")+": ponte de Jake"
			if Input.is_action_just_pressed(candidate.get_ability_action()):
				approach_actor=candidate
				approach.begin(candidate,offer_position(),offer_radius)
		else:
			for player in get_tree().get_nodes_in_group("players"):
				if accepts_actor(player) and player.global_position.distance_to(offer_position())<offer_radius:
					var reason: String=approach.path_reason(player,offer_position(),offer_radius)
					if reason!="ok": approach_hint.text=reason
		return

	_elapsed += delta
	var owner_ok := is_instance_valid(_jake) and _jake.has_ability(required_ability)
	if owner_ok:
		owner_ok = to_local(_jake.global_position).distance_to(_locked_origin) < 1.0
	var held := owner_ok and Input.is_action_pressed(_jake.get_ability_action()) and not _cancel_requested
	if not held:
		release_pending = true
	elif state == State.HOLDING:
		release_pending = false
	_set_prompt(owner_ok)

	match step:
		Step.SOURCE_EXTEND:
			if release_pending:
				_start_source_retraction(true)
			elif _elapsed >= _timeout:
				_start_growth()
		Step.GROW:
			if release_pending:
				_start_shrink()
			else:
				_progress = minf(1.0, _progress + delta / growth_duration)
				bridge_visual.set_progress(smoothstep(0.0, 1.0, _progress))
				if _progress >= 1.0:
					step = Step.WAIT_RENDER
					_elapsed = 0.0
		Step.WAIT_RENDER:
			if release_pending:
				_start_shrink()
			elif bridge_visual.has_full_render():
				_set_support(true)
				state = State.HOLDING
				step = Step.FULL
				_clear_ticks = 0
			elif _elapsed > 1.0:
				# Never invent an invisible floor if the visual cannot render.
				_start_shrink()
		Step.FULL:
			if release_pending:
				if get_dependents().is_empty():
					_clear_ticks += 1
					if _clear_ticks >= 2:
						_start_shrink()
				else:
					_clear_ticks = 0
		Step.SHRINK:
			_progress = maxf(0.0, _progress - delta / shrink_duration)
			bridge_visual.set_progress(smoothstep(0.0, 1.0, _progress))
			if _progress <= 0.0:
				_start_source_retraction(false)
		Step.SOURCE_RETRACT:
			if _elapsed >= _timeout:
				_finish_retraction()

func offer_position() -> Vector2:
	return to_global(formation_offset)

func accepts_actor(player: CoopPlayer) -> bool:
	return is_instance_valid(player) and player.has_ability(required_ability) and player.animated_sprite.sprite_frames.has_animation(&"bridge_extend") and player.animated_sprite.sprite_frames.get_frame_count(&"bridge_extend")>=4

func can_request(player: CoopPlayer) -> bool:
	return accepts_actor(player) and state==State.IDLE and approach!=null and approach.selected(player,offer_position(),offer_radius)

func _find_candidate() -> CoopPlayer:
	for body in get_tree().get_nodes_in_group("players"):
		if body is CoopPlayer and can_request(body): return body
	return null

func can_activate(player: CoopPlayer) -> bool:
	return can_request(player)

func _can_form(player: CoopPlayer) -> bool:
	if not is_instance_valid(player) or not player.has_ability(required_ability) or not player.is_on_floor() or player.movement_locked:
		return false
	var point := to_local(player.global_position)
	var bounds := activation_origin_rect.grow(0.001)
	if not bounds.has_point(point):
		return false
	var sprite := player.animated_sprite
	var frames := sprite.sprite_frames
	if frames == null or not frames.has_animation(&"bridge_extend") or frames.get_frame_count(&"bridge_extend") < 4:
		return false
	# Preserve the sprite's proportions under translated / uniformly scaled rooms.
	var relative := global_transform.affine_inverse() * sprite.global_transform
	var scale_x := relative.x.length()
	var scale_y := relative.y.length()
	if relative.x.x <= 0 or relative.y.y <= 0 or absf(relative.x.y) > 0.001 or absf(relative.y.x) > 0.001 or not is_equal_approx(scale_x, scale_y):
		return false
	var origin := relative.origin + (sprite.offset - Vector2(48, 40)) * scale_x
	var support := get_support_rect()
	var flat_start := origin.x + 30.0 * scale_x
	var right_section := support.end.x - 4.0 * scale_x
	return flat_start <= support.position.x + 0.001 and origin.x + 48.0 * scale_x <= right_section

func _begin_bridge(player: CoopPlayer) -> void:
	if approach!=null: approach.cancel()
	approach_hint.text=""
	_cancel_requested=false
	_jake = player
	_locked_origin = to_local(player.global_position)
	_sprite_was_visible = player.animated_sprite.visible
	player.movement_locked = true
	player.velocity = Vector2.ZERO
	player.face_direction(1.0)
	var sprite := player.animated_sprite
	var relative := global_transform.affine_inverse() * sprite.global_transform
	var uniform_scale := relative.x.length()
	var origin := relative.origin + (sprite.offset - Vector2(48, 40)) * uniform_scale
	var support := get_support_rect()
	var flat_start:=origin.x+30.0*uniform_scale
	var right:=support.end.x
	var shape_node=$BridgeBody/CollisionShape2D
	shape_node.shape=shape_node.shape.duplicate()
	shape_node.shape.size.x=right-flat_start
	$BridgeBody.position.x=(flat_start+right)*0.5
	support=get_support_rect()
	bridge_visual.configure(sprite.sprite_frames.get_frame_texture(&"bridge_extend", 3), origin, uniform_scale, support.end.x - 4.0 * uniform_scale, support.position.y)
	release_pending = false
	_progress = 0.0
	_clear_ticks = 0
	state = State.EXTENDING
	step = Step.SOURCE_EXTEND
	_set_support(false)
	if not sprite.animation_finished.is_connected(_on_jake_animation_finished):
		sprite.animation_finished.connect(_on_jake_animation_finished)
	_play_source(false, false)
	stretch_sfx.play()

func _play_source(reverse: bool, keep_current_frame: bool) -> void:
	_elapsed = 0.0
	_timeout = animation_timeout_margin
	if not is_instance_valid(_jake):
		return
	var sprite := _jake.animated_sprite
	var frame := sprite.frame
	var frame_progress := sprite.frame_progress
	_jake.animation_override = &"bridge_extend"
	_timeout += _jake.get_animation_duration(&"bridge_extend")
	if reverse:
		sprite.play_backwards(&"bridge_extend")
		if keep_current_frame:
			sprite.set_frame_and_progress(frame, frame_progress)
	else:
		sprite.play(&"bridge_extend")
		sprite.set_frame_and_progress(0, 0.0)

func _start_growth() -> void:
	if step != Step.SOURCE_EXTEND:
		return
	_elapsed = 0.0
	step = Step.GROW
	if is_instance_valid(_jake):
		_jake.animation_override = &"bridge_hold"
		_jake.animated_sprite.play(&"bridge_hold")
		_jake.animated_sprite.hide()
	bridge_visual.set_progress(0.0)
	bridge_visual.show()

func _start_shrink() -> void:
	if step == Step.SHRINK or step == Step.SOURCE_RETRACT:
		return
	# Called only with no dependents when support has been enabled.
	_set_support(false)
	state = State.RETRACTING
	step = Step.SHRINK
	_elapsed = 0.0
	retract_sfx.play()

func _start_source_retraction(from_current_frame: bool) -> void:
	_set_support(false)
	state = State.RETRACTING
	step = Step.SOURCE_RETRACT
	bridge_visual.hide()
	if not is_instance_valid(_jake):
		_finish_retraction()
		return
	_jake.animated_sprite.visible = _sprite_was_visible
	_play_source(true, from_current_frame)

func _finish_retraction() -> void:
	if approach!=null: approach.cancel()
	if is_instance_valid(approach_hint): approach_hint.text=""
	_set_support(false)
	bridge_visual.hide()
	_unlock_player()
	_jake = null
	state = State.IDLE
	step = Step.NONE
	release_pending = false
	_elapsed = 0.0
	_progress = 0.0
	_clear_ticks = 0

func _unlock_player() -> void:
	if not is_instance_valid(_jake):
		return
	_jake.animated_sprite.visible = _sprite_was_visible
	_jake.animation_override = &""
	_jake.movement_locked = false
	if _jake.animated_sprite.animation_finished.is_connected(_on_jake_animation_finished):
		_jake.animated_sprite.animation_finished.disconnect(_on_jake_animation_finished)
	_jake.animated_sprite.play(&"idle")

func get_support_rect() -> Rect2:
	var collider := $BridgeBody/CollisionShape2D as CollisionShape2D
	var shape := collider.shape as RectangleShape2D
	return _shape_rect(collider, shape.size)

func _shape_rect(collider: CollisionShape2D, size: Vector2) -> Rect2:
	var rect := Rect2()
	var first := true
	for corner in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
		var point := to_local(collider.global_transform * (corner * size * 0.5))
		if first:
			rect = Rect2(point, Vector2.ZERO)
			first = false
		else:
			rect = rect.expand(point)
	return rect

func get_dependents() -> Array[CoopPlayer]:
	var result: Array[CoopPlayer] = []
	var support := get_support_rect()
	for node in get_tree().get_nodes_in_group("players"):
		if node == _jake or not node is CoopPlayer:
			continue
		var player := node as CoopPlayer
		var collider := player.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if collider == null or not collider.shape is RectangleShape2D:
			continue
		var box := _shape_rect(collider, (collider.shape as RectangleShape2D).size)
		# Ground below the bridge on a bank is independent of its support.
		if player.is_on_floor() and player.velocity.y >= 0 and box.end.y > support.position.y + 3.0:
			continue
		var local_velocity := global_transform.basis_xform_inv(player.velocity)
		var predicted := Rect2(box.position + local_velocity * dependency_prediction_time, box.size)
		var swept := box.merge(predicted)
		# No upper Y limit: a jumping/falling partner can still need the bridge.
		if swept.end.x > support.position.x and swept.position.x < support.end.x and box.position.y < support.end.y + 2.0:
			result.append(player)
	return result

func _set_support(active: bool) -> void:
	_bridge_active = active
	bridge_body.collision_layer = 1 if active else 0
	bridge_body.collision_mask = 0
	if is_instance_valid(anchor_visual):
		anchor_visual.modulate = Color(1.35, 1.35, 1.0, 1.0) if active else Color.WHITE

func _set_prompt(show_prompt: bool) -> void:
	$ActivationMarker.modulate=Color(1.2,1.2,0.65) if show_prompt else Color.WHITE
	if _prompt_visible != show_prompt:
		_prompt_visible = show_prompt
		prompt_changed.emit(show_prompt)

func _on_jake_animation_finished() -> void:
	if step == Step.SOURCE_EXTEND:
		if release_pending:
			_start_source_retraction(true)
		else:
			_start_growth()
	elif step == Step.SOURCE_RETRACT:
		_finish_retraction()

func _exit_tree() -> void:
	if approach!=null: approach.cancel()
	_unlock_player()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_ESCAPE:
		if approach!=null and approach.active: approach.cancel()
		elif state!=State.IDLE: _cancel_requested=true
