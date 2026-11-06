extends SceneTree
## Reproducible extraction of generated masters into native-size game sprites.
const DIR = "res://Assets/03_Objects_and_Puzzles/pixel_refinement/"
func _initialize() -> void:
	for theme in ["cave", "candy"]:
		var src := Image.load_from_file(DIR+"sources/"+theme+"_master.png")
		var frame := Image.create(64,96,false,Image.FORMAT_RGBA8)
		var leaf: Image
		if theme=="cave":
			paste(frame,src,Rect2i(60,80,777,178),Vector2i(64,12),Vector2i.ZERO)
			paste(frame,src,Rect2i(98,258,158,650),Vector2i(8,80),Vector2i(0,12))
			paste(frame,src,Rect2i(606,258,155,650),Vector2i(8,80),Vector2i(56,12))
			paste(frame,src,Rect2i(60,908,777,88),Vector2i(64,4),Vector2i(0,92))
			leaf = piece(src,Rect2i(908,237,431,747),Vector2i(48,80))
		else:
			paste(frame,src,Rect2i(48,86,754,231),Vector2i(64,12),Vector2i.ZERO)
			paste(frame,src,Rect2i(48,317,207,635),Vector2i(8,80),Vector2i(0,12))
			paste(frame,src,Rect2i(597,317,205,635),Vector2i(8,80),Vector2i(56,12))
			paste(frame,src,Rect2i(48,952,754,54),Vector2i(64,4),Vector2i(0,92))
			leaf = piece(src,Rect2i(859,214,504,792),Vector2i(48,80))
		# The closed leaf must cover the entire existing physical rectangle.
		for y in leaf.get_height():
			for x in leaf.get_width():
				if leaf.get_pixel(x,y).a<0.8:leaf.set_pixel(x,y,Color("292039") if theme=="cave" else Color("4a272a"))
		limited_palette(frame,40);limited_palette(leaf,40)
		frame.save_png(DIR+theme+"_frame_80.png");leaf.save_png(DIR+theme+"_leaf_80.png")
		shorten(frame,[28,68]).save_png(DIR+theme+"_frame_64.png")
		shorten(leaf,[16,56]).save_png(DIR+theme+"_leaf_64.png")
	var circuit := Image.load_from_file(DIR+"sources/circuit_master.png")
	var panel := piece(circuit,Rect2i(10,5,1661,463),Vector2i(256,80))
	var housing := piece(circuit,Rect2i(19,468,525,462),Vector2i(64,64))
	var rotor := piece(circuit,Rect2i(575,541,430,343),Vector2i(48,40))
	# Retain the central hub, remove decorative axial stalks: conductor orientation
	# is readable by silhouette, including without colour discrimination.
	for y in rotor.get_height():
		if y<8 or y>=32:
			for x in rotor.get_width():rotor.set_pixel(x,y,Color.TRANSPARENT)
	for img in [panel,housing,rotor]:limited_palette(img,48)
	panel.save_png(DIR+"candy_circuit_backplate.png")
	housing.save_png(DIR+"candy_circuit_housing.png")
	rotor.save_png(DIR+"candy_circuit_rotor.png")
	print("Native pixel door and circuit sprites saved")
	quit()
func piece(src: Image,rect: Rect2i,size: Vector2i) -> Image:
	var out := src.get_region(rect);out.resize(size.x,size.y,Image.INTERPOLATE_NEAREST)
	for y in out.get_height():
		for x in out.get_width():
			var c:=out.get_pixel(x,y)
			if c.a<0.8:c=Color.TRANSPARENT
			else:c.a=1
			out.set_pixel(x,y,c)
	return out
func paste(dst: Image,src: Image,rect: Rect2i,size: Vector2i,at: Vector2i) -> void:
	var part:=piece(src,rect,size);dst.blit_rect(part,Rect2i(Vector2i.ZERO,size),at)
func shorten(src: Image,cuts: Array) -> Image:
	var out:=Image.create(src.get_width(),src.get_height()-16,false,Image.FORMAT_RGBA8)
	var row:=0
	for y in src.get_height():
		if (y>=cuts[0] and y<cuts[0]+8) or (y>=cuts[1] and y<cuts[1]+8):continue
		out.blit_rect(src,Rect2i(0,y,src.get_width(),1),Vector2i(0,row));row+=1
	return out
func limited_palette(img: Image,count: int) -> void:
	# Deterministic RGB clustering; no blur, resampling filter or dithering.
	var samples: Array[Vector3]=[]
	for y in img.get_height():
		for x in img.get_width():
			var c:=img.get_pixel(x,y)
			if c.a>0.5:samples.append(Vector3(c.r,c.g,c.b))
	var palette: Array[Vector3]=[]
	for n in count:palette.append(samples[(n*samples.size()/count) as int])
	for iteration in 10:
		var sums: Array[Vector3]=[];sums.resize(count);sums.fill(Vector3.ZERO)
		var numbers: Array[int]=[];numbers.resize(count);numbers.fill(0)
		for v in samples:
			var nearest:=0;var distance:=INF
			for n in count:
				var d:=v.distance_squared_to(palette[n])
				if d<distance:nearest=n;distance=d
			sums[nearest]+=v;numbers[nearest]+=1
		for n in count:
			if numbers[n]>0:palette[n]=sums[n]/numbers[n]
	for y in img.get_height():
		for x in img.get_width():
			var c:=img.get_pixel(x,y)
			if c.a<0.5:continue
			var v:=Vector3(c.r,c.g,c.b);var nearest:=0;var distance:=INF
			for n in count:
				var d:=v.distance_squared_to(palette[n])
				if d<distance:nearest=n;distance=d
			var p:=palette[nearest];img.set_pixel(x,y,Color(p.x,p.y,p.z,1))
