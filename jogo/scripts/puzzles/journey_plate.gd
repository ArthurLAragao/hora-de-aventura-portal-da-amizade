extends "res://scripts/puzzles/pressure_plate.gd"
## Environment-local finish; trigger geometry and capability rules stay unchanged.
@export var required_ability: StringName = &""
@export var visual_kind: StringName = &"step"
@export var completed:=false
@export var available:=true
var _last_visual:=""
## Filtra o corpo por tipo/capacidade conforme a regra da placa.
func _is_accepted(body: Node2D) -> bool:
	if required_ability!=&"": return body is CoopPlayer and body.has_ability(required_ability)
	return super._is_accepted(body)
## Sincroniza o desenho da placa com seu estado físico/lógico.
func _set_visual(pressed: bool) -> void:
	super._set_visual(pressed)
	plate_sprite.hide()
	z_index=1
	queue_redraw()
## Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: apresentação das placas da jornada.
func _process(_dt: float) -> void:
	var state:=visual_state()
	if state!=_last_visual:_last_visual=state;queue_redraw()
## Expõe o estado visual da placa para apresentação e inspeção.
func visual_state() -> String:
	return "complete" if completed else ("pressed" if is_active() else ("available" if available else "inactive"))
## Desenha a apresentação local; este método não concede progresso nem altera colisões. Contexto: apresentação das placas da jornada.
func _draw() -> void:
	var forest:=get_parent()!=null and get_parent().has_node("TutorialLog")
	var ink:=Color("203941")
	var side:=Color("6b4d36") if forest else Color("365966")
	var surface:=Color("ba8b50") if forest else Color("769d9c")
	var metal:=Color("dba754") if available else Color("68838c")
	var light:=Color("a5ebc1") if completed else (Color("ffe79b") if is_active() else metal)
	var gathering:=visual_kind in [&"reunion",&"confirm"]
	# A recessed paving slab for gathering; a raised, compressible tread for weight.
	var corners:=PackedVector2Array([Vector2(-39,-3),Vector2(-33,-7),Vector2(33,-7),Vector2(39,-3),Vector2(35,3),Vector2(-35,3)])
	draw_colored_polygon(corners,ink)
	draw_rect(Rect2(-34,-4,68,6),side)
	draw_rect(Rect2(-32,-4,64,3),surface)
	if forest:
		for x in [-24,-8,8,24]:draw_line(Vector2(x,-3),Vector2(x,1),side,1)
	else:
		draw_line(Vector2(-15,-3),Vector2(-13,0),side,1)
		draw_line(Vector2(14,-3),Vector2(16,0),side,1)
	if gathering:
		# Inlaid footprints stay in the stone, with no floating badge or interaction key.
		for x in [-11,7]:
			draw_rect(Rect2(x,-5,5,3),light if is_active() or completed else ink)
			draw_rect(Rect2(x+1,-7,3,2),light if is_active() or completed else ink)
	else:
		var y: int=-4 if is_active() or completed else -10
		draw_rect(Rect2(-24,y,48,7),ink)
		draw_rect(Rect2(-22,y+1,44,4),surface)
		for x in [-16,-5,6,17]:draw_line(Vector2(x,y+1),Vector2(x,y+4),side,1)
		# Weight/ability cue is an engraving in the tread, not an upright UI tile.
		if accepts_pushables:draw_rect(Rect2(-5,y+1,10,3),side)
		elif required_ability==&"bridge":draw_line(Vector2(-7,y+2),Vector2(7,y+2),metal,2)
	# Exposed end caps remain visible beside a body or the existing 58px log.
	for x in [-37,29]:
		draw_rect(Rect2(x,-9 if gathering else -7,8,10),ink)
		draw_rect(Rect2(x+1,-8 if gathering else -6,6,5),metal)
		draw_rect(Rect2(x+2,-6 if gathering else -4,4,2),light)
		if completed:draw_line(Vector2(x+2,-7),Vector2(x+5,-4),ink,1)
		elif not available:draw_rect(Rect2(x+2,-7,4,4),side)
