extends Node2D
## Variante local de alavanca em madeira e cobre: contorno nativo, sem deformar a imagem antiga.
var lever: Area2D
var before:=false
func _ready() -> void:
	lever=get_parent();lever.get_node("Sprite2D").hide();texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;z_index=1
func _process(_delta: float) -> void:
	if before!=lever._is_activated:before=lever._is_activated;queue_redraw()
func _draw() -> void:
	if lever==null:return
	draw_rect(Rect2(-24,22,48,10),Color("293d36"));draw_rect(Rect2(-21,23,42,7),Color("91643b"))
	for x in [-18,-5,8]:draw_rect(Rect2(x,25,9,2),Color("bf985c"))
	draw_colored_polygon(PackedVector2Array([Vector2(-15,23),Vector2(-10,5),Vector2(10,5),Vector2(15,23)]),Color("394847"))
	draw_rect(Rect2(-8,9,16,11),Color("889886"));draw_circle(Vector2(0,14),4,Color("d5b86d"))
	var tip:=Vector2(13 if before else -13,-13)
	draw_line(Vector2(0,13),tip,Color("263938"),8);draw_line(Vector2(0,12),tip,Color("b29a67"),4)
	draw_rect(Rect2(tip-Vector2(6,6),Vector2(12,12)),Color("263938"));draw_rect(Rect2(tip-Vector2(4,4),Vector2(8,7)),Color("86bb88") if before else Color("c87952"))
