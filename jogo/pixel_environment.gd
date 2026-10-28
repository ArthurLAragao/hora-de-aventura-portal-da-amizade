@tool
extends RefCounted
## Import adapter for the new imagegen art only. Original PNGs are never rewritten.
static var cache: Dictionary={}
static func texture(path: String,width: int) -> Texture2D:
	var key:=path+":"+str(width)
	if cache.has(key):return cache[key]
	var image: Image=load(path).get_image()
	if image.is_compressed():image.decompress()
	image.convert(Image.FORMAT_RGBA8)
	image=image.get_region(image.get_used_rect())
	var height:=maxi(1,roundi(float(image.get_height())*width/image.get_width()))
	image.resize(width,height,Image.INTERPOLATE_NEAREST)
	# Crisp alpha at the logical pixel scale, without halos around transparent foliage.
	for y in image.get_height():
		for x in image.get_width():
			var c:=image.get_pixel(x,y)
			c.a=1.0 if c.a>=0.5 else 0.0
			image.set_pixel(x,y,c)
	var result:=ImageTexture.create_from_image(image)
	cache[key]=result
	return result
