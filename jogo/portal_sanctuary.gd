@tool
extends Node2D
## Local variant uses a new raster; original portal textures are preserved.
const ART=preload("res://Assets/03_Objects_and_Puzzles/sprites/portal_sanctuary_v2.png")
const FX=[preload("res://Assets/05_Effects/frames/portal/portal_00.png"),preload("res://Assets/05_Effects/frames/portal/portal_01.png"),preload("res://Assets/05_Effects/frames/portal/portal_02.png"),preload("res://Assets/05_Effects/frames/portal/portal_03.png")]
const REGION=Rect2(90,195,1022,960)
var texture: Texture2D:
	set(value):
		texture=value
		queue_redraw()
var repairs: Array=[false,false,false]:
	set(value):
		repairs=value.duplicate()
		queue_redraw()
var clock:=0.0
func _process(dt: float) -> void:
	if repairs.all(func(v):return v):clock+=dt;queue_redraw()
func _draw() -> void:
	var height:=80.0*REGION.size.y/REGION.size.x
	var opening:=PackedVector2Array([Vector2(-15,-7),Vector2(-15,-43),Vector2(-10,-55),Vector2(0,-58),Vector2(10,-55),Vector2(15,-43),Vector2(15,-7)])
	if repairs.all(func(v):return v):
		draw_colored_polygon(opening,Color("246b83"))
		var frame: int=int(clock*8)%4
		var fx=FX[frame]
		draw_texture_rect_region(fx,Rect2(-15,-49,30,30),Rect2(16,16,32,32))
	else:draw_colored_polygon(opening,Color(0.07,0.14,0.22,0.45))
	draw_texture_rect_region(ART,Rect2(-40,-height,80,height),REGION,Color.WHITE if repairs[0] else Color(0.70,0.76,0.85))
