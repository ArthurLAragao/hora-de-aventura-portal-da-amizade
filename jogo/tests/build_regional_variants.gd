extends SceneTree
func _initialize() -> void:
	var names:=["02_ice_kingdom","03_musical_cave","04_candy_workshop"]
	var tags:=["ice","cave","candy"]
	for i in 3:
		var original:=(load("res://Assets/02_Environments/"+names[i]+"/tileset_32.png") as Texture2D).get_image()
		for v in 3:
			var atlas:=original.duplicate() as Image
			var detail:=(load("res://Assets/02_Environments/regional_refinement/"+tags[i]+"_ground_"+["a","b","c"][v]+".png") as Texture2D).get_image()
			# Keep original surface and tile boundaries exact; vary only solid material.
			for ty in 3:
				for tx in 3:
					for y in range(12 if ty==0 else 4,28):
						for x in range(4,28):
							var target:=Vector2i(tx*32+x,ty*32+y)
							var old:=atlas.get_pixelv(target)
							var sample:=detail.get_pixel(6+posmod(x+v*5,20),16+posmod(y+v*3,12))
							if old.a>0.99 and sample.a>0.99:
								atlas.set_pixelv(target,old.lerp(sample,0.25))
			atlas.save_png("res://Assets/02_Environments/regional_refinement/"+tags[i]+"_terrain_"+str(v)+".png")
	print("9 terrain atlas variants, original top/side boundaries retained")
	quit()
