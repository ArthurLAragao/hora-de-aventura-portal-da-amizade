extends Node2D
## Postes fixos e folha em PNG; a retração visual usa a textura original sem esticá-la.
const ART=preload("res://Assets/03_Objects_and_Puzzles/local_finish/forest_gate_oak.png")
var gate: CoopGate
var previous:=false
var progress:=0.0
func _ready() -> void:
	gate=get_parent();gate.gate_sprite.hide();texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;z_index=1
func _process(delta: float) -> void:
	previous=gate.is_open
	var next:=move_toward(progress,1.0 if previous else 0.0,delta/0.28)
	if not is_equal_approx(next,progress):progress=next;queue_redraw()
func _draw() -> void:
	if gate==null:return
	var height: float=gate.collision_shape.shape.size.y;var factor:=height/104.0;var origin:=Vector2(-62*factor,-height*0.5)
	for x in [0,100]:draw_texture_rect_region(ART,Rect2(origin+Vector2(x*factor,0),Vector2(24,104)*factor),Rect2(x,0,24,104))
	var rows:=104-roundi(progress*104)
	if rows>0:draw_texture_rect_region(ART,Rect2(origin+Vector2(24*factor,0),Vector2(76,rows)*factor),Rect2(24,104-rows,76,rows),Color(1,1,1,1-progress*0.35))
