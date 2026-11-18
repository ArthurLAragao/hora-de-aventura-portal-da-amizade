extends Node2D
## Vida ambiental discreta: desenhos de fundo e sombras de contato, sem colisão ou efeitos globais.
@export_range(1,6) var phase:=1
var clock:=0.0
var shadows: Node2D
var drift: Node2D
func _ready() -> void:
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	shadows=Node2D.new();shadows.z_index=-1;shadows.draw.connect(draw_shadows);add_child(shadows)
	drift=Node2D.new();drift.z_index=-7;drift.draw.connect(draw_drift);add_child(drift)
func _process(delta: float) -> void:
	clock+=delta;shadows.queue_redraw();drift.queue_redraw()
func draw_shadows() -> void:
	for actor in get_tree().get_nodes_in_group("players"):
		if not actor.is_visible_in_tree() or not actor.is_on_floor():continue
		var shape: CollisionShape2D=actor.get_node("CollisionShape2D")
		var feet:=shape.global_transform*Vector2(0,shape.shape.size.y*0.5)
		var at:=shadows.to_local(feet).round()
		shadows.draw_rect(Rect2(at-Vector2(12,1),Vector2(24,2)),Color("132b3a50"))
func draw_drift() -> void:
	var width:=2600
	if phase in [1,2,6]:
		for i in 5:
			var x:=fmod(i*537+clock*(2+i%2),width+180)-90
			var y:=90+i%3*37
			var color:=Color("d5eee91c") if phase!=6 else Color("edc5cb18")
			drift.draw_rect(Rect2(x,y,82,6),color);drift.draw_rect(Rect2(x+16,y-5,44,5),color);drift.draw_rect(Rect2(x+9,y+6,65,3),color)
	for i in 14:
		var at:=Vector2(fmod(i*179+clock*(2+phase),width),190+fmod(i*47+clock*(2 if phase!=2 else 5),180))
		var color: Color={1:Color("bfd18150"),2:Color("dce9f057"),3:Color("93c6d34d"),4:Color("edbb7152"),5:Color("e9d7ab4d"),6:Color("a0e0cd62")}[phase]
		drift.draw_rect(Rect2(at.round(),Vector2(2,2)),color)
