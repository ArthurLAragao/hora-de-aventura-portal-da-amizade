extends Node2D
## Acabamento de placa específico da caverna/oficina; a Area2D original detecta o peso.
@export var region:=3
var plate: PressurePlate
var state:=""
var completed:=false

## Oculta somente o sprite genérico; alcance e aceitação do mecanismo são preservados.
func _ready() -> void:
	plate=get_parent();plate.plate_sprite.hide();z_index=3
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST

## A placa abaixa durante a pressão e permanece iluminada quando o puzzle é conquistado.
func _process(_delta: float) -> void:
	var level:=plate.get_parent()
	if region==3:completed=level.confirmation_solved
	else:completed=level.get_node("Gate").is_open
	var next:=str(plate.is_active())+str(completed)
	if state!=next:state=next;queue_redraw()

## Pedra violeta e ressonador gravado; ou trilho de biscoito com mecanismo de cobre.
func _draw() -> void:
	if plate==null:return
	var down:=plate.is_active() or completed
	var y: int=-4 if down else -9
	var ink:=Color("29273e") if region==3 else Color("563a45")
	var base:=Color("595674") if region==3 else Color("a7755b")
	var edge:=Color("9ca1bc") if region==3 else Color("edc49a")
	var glow:=Color("baf1db") if down else Color("665d7c") if region==3 else Color("705e55")
	draw_rect(Rect2(-37,-3,74,6),ink);draw_rect(Rect2(-33,-3,66,4),base)
	draw_rect(Rect2(-27,y,54,6),ink);draw_rect(Rect2(-25,y+1,50,3),edge)
	for x in [-37,28]:
		draw_rect(Rect2(x,-7,9,9),ink);draw_rect(Rect2(x+1,-6,7,3),base)
		draw_rect(Rect2(x+2,-5,5,2),glow)
	if region==3:
		for x in [-12,-2,8]:draw_rect(Rect2(x,y+1,4,2),ink)
		# Cristais nas laterais identificam a placa mesmo com alguém sobre o centro.
		for x in [-34,31]:
			draw_colored_polygon(PackedVector2Array([Vector2(x,-10),Vector2(x+3,-14),Vector2(x+6,-10),Vector2(x+5,-6),Vector2(x+1,-6)]),glow if down else edge)
	else:
		for x in [-18,-6,6,18]:draw_rect(Rect2(x,y+1,2,3),base)
		for x in [-32,30]:draw_rect(Rect2(x,-2,2,3),edge)
