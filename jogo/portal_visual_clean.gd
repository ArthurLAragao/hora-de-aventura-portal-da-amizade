extends Node2D
## Lossless render-only variant: omit the disconnected alpha fragments of portal_repaired.png.
## All original PNGs, colors and remaining pixels are untouched.
var texture: Texture2D:
	set(value):
		texture=value
		queue_redraw()
const CLEAN_REGIONS=[
Rect2(0,0,128,9),Rect2(0,9,111,1),Rect2(112,9,1,1),Rect2(114,9,3,1),Rect2(119,9,9,1),Rect2(0,10,112,1),Rect2(115,10,2,1),Rect2(118,10,10,1),Rect2(0,11,116,1),Rect2(117,11,11,1),Rect2(0,12,112,1),Rect2(115,12,13,1),Rect2(0,13,128,45),Rect2(0,58,76,2),Rect2(77,58,51,2),Rect2(0,60,128,68)]
func _draw() -> void:
	if texture==null: return
	if texture.resource_path.ends_with("portal_repaired.png"):
		for region in CLEAN_REGIONS:
			draw_texture_rect_region(texture,Rect2(region.position-Vector2(64,64),region.size),region)
	else: draw_texture(texture,-texture.get_size()*0.5)
