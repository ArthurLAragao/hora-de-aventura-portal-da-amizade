extends "res://pressure_plate.gd"
## Local art for the two journey scenes. Trigger geometry and capability rules are unchanged.
@export var required_ability: StringName = &""
@export var visual_kind: StringName = &"step"
@export var completed:=false
@export var available:=true
func _is_accepted(body: Node2D) -> bool:
	if required_ability!=&"": return body is CoopPlayer and body.has_ability(required_ability)
	return super._is_accepted(body)
func _set_visual(pressed: bool) -> void:
	super._set_visual(pressed)
	plate_sprite.hide()
	z_index=1
	queue_redraw()
func _process(_dt: float) -> void:
	queue_redraw()
func visual_state() -> String:
	return "complete" if completed else ("pressed" if is_active() else ("available" if available else "inactive"))
func _draw() -> void:
	var ink:=Color("142a36")
	var trim:=Color("dba754") if available else Color("68838c")
	var lit:=Color("ffe79b") if is_active() else Color("b88346")
	if not available: lit=Color("536e7c")
	if completed: lit=Color("a5ebc1")
	if visual_kind in [&"reunion",&"confirm"]:
		draw_colored_polygon(PackedVector2Array([Vector2(-30,-4),Vector2(-22,-9),Vector2(22,-9),Vector2(30,-4),Vector2(22,3),Vector2(-22,3)]),ink)
		draw_colored_polygon(PackedVector2Array([Vector2(-26,-4),Vector2(-20,-6),Vector2(20,-6),Vector2(26,-4),Vector2(20,0),Vector2(-20,0)]),trim)
		draw_line(Vector2(-18,-3),Vector2(18,-3),lit,3)
		# Two small uprights distinguish a gathering seal from a weight switch.
		for x in [-24,24]:
			draw_rect(Rect2(x-2,-23,4,18),ink)
			draw_rect(Rect2(x-1,-22,2,9),lit)
	else:
		draw_rect(Rect2(-36,-7,72,9),ink)
		draw_rect(Rect2(-34,-5,68,5),Color("6a8590"))
		draw_rect(Rect2(-19,-4 if is_active() else -10,38,5),ink)
		draw_rect(Rect2(-17,-3 if is_active() else -8,34,3),lit)
		for x in [-33,25]: draw_rect(Rect2(x,-5,8,3),trim if not is_active() else lit)
	var badge_x:=38 if accepts_pushables else -38
	draw_line(Vector2(signf(badge_x)*26,-4),Vector2(badge_x,-4),ink,3)
	draw_set_transform(Vector2(badge_x,0))
	draw_rect(Rect2(-2,-13,4,9),ink)
	draw_rect(Rect2(-1,-12,2,7),trim)
	# An enamel emblem is attached to the rim, not a floating instruction label.
	draw_rect(Rect2(-8,-28,16,17),ink)
	draw_rect(Rect2(-6,-26,12,12),trim)
	if completed:
		draw_polyline(PackedVector2Array([Vector2(-4,-20),Vector2(-1,-17),Vector2(5,-23)]),ink,2)
	elif accepts_pushables:
		draw_rect(Rect2(-4,-22,8,5),ink)
		draw_line(Vector2(-2,-22),Vector2(-2,-17),trim,1)
	elif required_ability==&"bridge":
		draw_polyline(PackedVector2Array([Vector2(-4,-17),Vector2(-4,-21),Vector2(4,-21),Vector2(4,-17)]),ink,2)
	elif required_ability==&"music":
		draw_line(Vector2(2,-23),Vector2(2,-18),ink,2)
		draw_rect(Rect2(-2,-19,4,3),ink)
	elif required_ability==&"terminal":
		draw_rect(Rect2(-4,-23,8,7),ink)
		draw_rect(Rect2(-2,-21,4,2),trim)
	else:
		draw_colored_polygon(PackedVector2Array([Vector2(0,-24),Vector2(4,-20),Vector2(0,-16),Vector2(-4,-20)]),ink)
