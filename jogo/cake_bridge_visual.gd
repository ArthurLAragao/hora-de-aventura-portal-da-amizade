extends Node2D
const CENTER = preload("res://Assets/01_Characters/cake/bridge/center.png")
var frame: Texture2D
var progress := 0.0
var full_rendered := false
func set_progress(value: float) -> void:
	progress=clampf(value,0,1)
	if progress<1: full_rendered=false
	queue_redraw()
func has_full_render() -> bool:
	return is_visible_in_tree() and progress>=1 and (full_rendered or DisplayServer.get_name()=="headless")
func _draw() -> void:
	if frame==null: return
	var length := roundi(progress*88)
	draw_texture_rect_region(frame,Rect2(-48,-40,52,80),Rect2(0,0,52,80))
	if length>0:
		var back_length:=roundi(progress*108)
		var cursor:=0
		while cursor<back_length:
			var width:=mini(88,back_length-cursor)
			draw_texture_rect_region(CENTER,Rect2(4+cursor,20,width,9),Rect2(0,0,width,9))
			cursor+=width
	draw_texture_rect_region(frame,Rect2(4+length,-40+roundi(progress*4),44,80),Rect2(52,0,44,80))
	full_rendered=progress>=1
