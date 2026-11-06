extends SceneTree
func _initialize() -> void:
	var image:=(load("res://Assets/02_Environments/regional_refinement/ice_tunnel_wall_source.png") as Texture2D).get_image()
	image.resize(32,32,Image.INTERPOLATE_NEAREST)
	image.save_png("res://Assets/02_Environments/regional_refinement/ice_tunnel_wall_detail.png")
	quit()
