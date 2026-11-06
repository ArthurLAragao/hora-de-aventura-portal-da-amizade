extends Node2D
## Placa embutida no piso do santuário. Observa estados, sem mudar alcance ou ativação.
var plate: Area2D
var previous:=""
const INK=Color("1d363d")
const STONE=Color("477478")
const EDGE=Color("83aaa0")
const BRASS=Color("b69c64")

## Substitui apenas o desenho do nó pai, preservando sua lógica e os filhos.
func _ready() -> void:
	plate=get_parent();plate.self_modulate.a=0.0;z_index=2
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST

## Redesenha somente quando disponibilidade, pressão ou conquista mudam.
func _process(_delta: float) -> void:
	var state: String=plate.visual_state()
	if state!=previous:previous=state;queue_redraw()

## Pedra chanfrada, aro de bronze e ranhuras: os estados também diferem em relevo.
func _draw() -> void:
	if plate==null:return
	var pressed: bool=plate.is_active() or plate.completed
	var tread_y: int=-3 if pressed else -7
	var glow:=Color("ccebc4") if plate.completed else Color("f1d294") if pressed else Color("36565c")
	# Base rebaixada: a borda inferior entra dois pixels no material do chão.
	draw_colored_polygon(PackedVector2Array([Vector2(-38,-3),Vector2(-30,-7),Vector2(30,-7),Vector2(38,-3),Vector2(34,3),Vector2(-34,3)]),INK)
	draw_rect(Rect2(-34,-3,68,5),STONE)
	draw_line(Vector2(-30,1),Vector2(30,1),Color("284c55"),2)
	draw_rect(Rect2(-25,tread_y,50,5),INK)
	draw_rect(Rect2(-23,tread_y+1,46,3),EDGE if plate.available else STONE)
	# Duas pegadas gravadas distinguem reunião/confirmação de peso de objeto.
	if plate.visual_kind in [&"reunion",&"confirm"]:
		for x in [-10,6]:
			draw_rect(Rect2(x,tread_y+1,5,2),INK)
			draw_rect(Rect2(x+1,tread_y,3,1),INK)
	else:
		draw_rect(Rect2(-7,tread_y+1,14,2),INK)
	# As duas luzes ficam fora do corpo e continuam legíveis quando alguém pisa.
	for x in [-36,27]:
		draw_rect(Rect2(x,-5,9,6),INK)
		draw_rect(Rect2(x+1,-5,7,2),BRASS)
		draw_rect(Rect2(x+2,-3,5,2),glow)
		if plate.completed:draw_rect(Rect2(x+3,-6,3,1),Color("e9dfac"))
	# Conexões curtas embutidas no piso não parecem peças de interface flutuando.
	for x in [-47,41]:
		draw_rect(Rect2(x,2,7,2),Color("284c55"))
		draw_rect(Rect2(x+1,2,5,1),BRASS if plate.completed else STONE)
