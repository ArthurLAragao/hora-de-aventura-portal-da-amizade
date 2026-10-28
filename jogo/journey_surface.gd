extends Node2D
## Native tile regions repeated at 1:1. Collider and visible top share their origin.
var size:=Vector2(64,12)
var top: Texture2D
var fill: Texture2D
func _draw() -> void:
	if top==null: return
	for x in range(0,int(size.x),32):
		var width:=minf(32,size.x-x)
		var h:=minf(12,size.y)
		draw_texture_rect_region(top,Rect2(x,0,width,h),Rect2(0,17,width,h))
		var y:=h
		while y<size.y:
			var height:=minf(32,size.y-y)
			draw_texture_rect_region(fill,Rect2(x,y,width,height),Rect2(0,0,width,height))
			y+=height
