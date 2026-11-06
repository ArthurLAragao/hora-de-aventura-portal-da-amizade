extends Node2D
## Acabamento local dos portões da trilha. CoopGate continua dono da colisão e do som.
const ART=preload("res://Assets/03_Objects_and_Puzzles/local_finish/forest_gate_oak.png")
var gate: CoopGate
var previous:=false

## Usa o tamanho físico existente, sem mover o portão ou a âncora vizinha.
func _ready() -> void:
	gate=get_parent();gate.gate_sprite.hide();texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;z_index=1
	queue_redraw()

## A apresentação acompanha a abertura original, inclusive após recuperação.
func _process(_delta: float) -> void:
	if previous!=gate.is_open:previous=gate.is_open;queue_redraw()

## Aberto: permanecem somente os dois postes, sem folha invisível ou colisão nova.
func _draw() -> void:
	if gate==null:return
	var size: Vector2=gate.collision_shape.shape.size
	var h:=size.y
	var factor:=h/104.0
	var origin:=Vector2(-62*factor,-h*0.5)
	if not gate.is_open:
		draw_texture_rect(ART,Rect2(origin,Vector2(124,104)*factor),false)
	else:
		for x in [0,100]:
			draw_texture_rect_region(ART,Rect2(origin+Vector2(x*factor,0),Vector2(24,104)*factor),Rect2(x,0,24,104))
