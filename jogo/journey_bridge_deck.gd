extends Node2D
const WOOD=preload("res://Assets/03_Objects_and_Puzzles/sprites/wooden_bridge.png")
func _draw() -> void:
	var x: float=-88
	while x<88:
		var width:=minf(28,88-x)
		draw_texture_rect_region(WOOD,Rect2(x,-9,width,18),Rect2(18,33,width,18))
		x+=width
