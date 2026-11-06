extends SceneTree
const SOURCE="res://Assets/02_Environments/regional_refinement/source_atlas.png"
func _initialize() -> void:
	var source:=(load(SOURCE) as Texture2D).get_image()
	var output:="res://Assets/02_Environments/regional_refinement"
	DirAccess.make_dir_recursive_absolute(output)
	var cw:=source.get_width()/8
	var rows:=[[64,230],[240,400],[408,560],[576,728],[736,888],[896,1056]]
	var regions:=["ice","cave","candy"]
	var terrain:=["ground_a","ground_b","ground_c","edge_left","edge_right","bottom","corner","platform"]
	var props:=["grass_a","grass_b","grass_c","bush_a","bush_b","column","vine","lantern"]
	for row in 6:
		for col in 8:
			var patch:=source.get_region(Rect2i(col*cw,rows[row][0],cw,rows[row][1]-rows[row][0]))
			for y in patch.get_height():
				for x in patch.get_width():
					if patch.get_pixel(x,y).a<0.8:patch.set_pixel(x,y,Color.TRANSPARENT)
			var used:=patch.get_used_rect()
			patch=patch.get_region(used)
			var factor:=minf(32.0/patch.get_width(),32.0/patch.get_height())
			patch.resize(maxi(1,int(patch.get_width()*factor)),maxi(1,int(patch.get_height()*factor)),Image.INTERPOLATE_NEAREST)
			var tile:=Image.create(32,32,false,Image.FORMAT_RGBA8)
			tile.fill(Color.TRANSPARENT)
			tile.blit_rect(patch,Rect2i(Vector2i.ZERO,patch.get_size()),Vector2i((32-patch.get_width())/2,32-patch.get_height()))
			patch=tile
			for y in 32:
				for x in 32:
					var c:=patch.get_pixel(x,y)
					if c.a<0.8:patch.set_pixel(x,y,Color.TRANSPARENT)
			var label: String=terrain[col] if row%2==0 else props[col]
			patch.save_png(output+"/"+regions[row/2]+"_"+label+".png")
	print("48 local 32x32 variants extracted, original images unchanged")
	quit()
