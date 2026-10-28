@tool
extends Node2D
## Layout and art used exclusively by levels 2–4; all tile collision data is copied intact.
var region:=2
var glow: Array[Sprite2D]=[]
var time:=0.0
var floor_y:=519.0
var terrain_variants: Array[TileSetAtlasSource]=[]
var layers: Dictionary={}
const ART="res://Assets/02_Environments/regional_refinement/"
var tag: String
func _ready() -> void:
	tag={2:"ice",3:"cave",4:"candy"}[region]
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	for spec in [["Distant",-5],["Structures",-3],["Vegetation",-1],["GroundDetails",1]]:
		var layer:=Node2D.new();layer.name=spec[0];layer.z_index=spec[1];add_child(layer);layers[spec[0]]=layer
	if region==2:_ice()
	elif region==3:_cave()
	else:_candy()
	_skin_terrain.call_deferred()

func prop(kind: String,x: int,y: int,s: int,layer: String="Vegetation",shade: Color=Color.WHITE,flip: bool=false) -> Sprite2D:
	var sprite:=Sprite2D.new()
	sprite.texture=load(ART+tag+"_"+kind+".png")
	var used:=sprite.texture.get_image().get_used_rect()
	sprite.position=Vector2(x,y-(used.end.y-16)*s)
	sprite.scale=Vector2.ONE*s;sprite.flip_h=flip;sprite.modulate=shade
	sprite.name=kind+"_"+str(x);sprite.set_meta("support_y",y)
	layers[layer].add_child(sprite)
	if kind=="lantern":glow.append(sprite)
	return sprite

func _ice() -> void:
	# Three natural clearings: frozen grove, covered tunnel, broken viaduct.
	for x in [48,240,1016,1192,1840,2200]:prop("bush_a",x,(487 if x==1192 else 455 if x==1328 else 519),3,"Distant",Color("adc7dd"))
	for x in [88,288,1088,1328,1776,2240]:prop("bush_b",x,(455 if x==1328 else 519),2,"Structures",Color("ccdfec"))
	for x in [32,192,1016,1192,1360,1792,1888,2072,2280]:prop(["grass_a","grass_b","grass_c"][posmod(x/8,3)],x,(487 if x in [1192,1360,2072] else 519),1)
	for x in [32,1088,1888,2256]:prop("column",x,519,2,"Structures")
	for x in [432,624]:prop("lantern",x,451,1,"Structures")
	for x in [460,588]:prop("vine",x,490,1,"Distant")
	# Deliberate low groups frame the start, reunion clearing and ridge landings.
	for spec in [[80,519,"grass_a"],[224,519,"grass_b"],[944,519,"grass_c"],[1224,487,"grass_b"],[1352,487,"grass_c"],[1944,519,"grass_a"],[2168,519,"grass_b"]]:
		prop(spec[2],spec[0],spec[1],1,"Vegetation",Color("d6e8eb"))

func _cave() -> void:
	# Dark ruins frame the crystal pools; distinct alcoves surround the instruments.
	for x in [48,384,912,1168,1408,1776,2136]:prop("bush_a",x,394,3,"Distant",Color("706b9a"))
	for x in [176,880,1376,1760,2128]:prop("bush_b",x,394,2,"Structures",Color("a5b8bd"))
	for x in [48,368,912,1152,1392,1776,2144]:prop("column",x,394,2,"Structures",Color("8988ad"))
	for x in [32,160,400,896,1184,1392,1648,2112]:prop(["grass_a","grass_b","grass_c"][posmod(x/16,3)],x,394,1)
	for x in [488,536]:prop("vine",x,352,2,"Distant",Color("7587b0"))
	prop("vine",1416,390,2,"Distant",Color("7587b0"))
	for x in [464,1016,1536,2048]:prop("lantern",x,230,1,"Structures")

func _candy() -> void:
	# Factory bays have their own columns and planters; leave terminals and plate clear.
	for x in [40,224,928,1152,1760,2128]:prop("column",x,388,3,"Distant",Color("c7b8b5"))
	for x in [112,944,1808,2144]:prop("bush_a",x,388,2,"Structures")
	for x in [192,1136,1752,2080]:prop("bush_b",x,388,2,"Structures")
	for x in [32,160,912,1184,1776,2136]:prop(["grass_a","grass_b","grass_c"][posmod(x/16,3)],x,388,1)
	for x in [64,960,1776,2144]:prop("vine",x,328,2,"Distant",Color("b2b8a8"))
	for x in [160,976,1440,1920]:prop("lantern",x,210,1,"Structures")

func _skin_terrain() -> void:
	var level:=get_parent().get_parent()
	for name in (["Terrain","Roof"] if region==2 else ["TileMapLayer"]):
		var map=level.get_node_or_null(name)
		if map==null:continue
		var set: TileSet=map.tile_set.duplicate(true)
		var base:=set.get_source(0) as TileSetAtlasSource
		for v in 3:
			var source:=base.duplicate(true) as TileSetAtlasSource
			source.texture=load(ART+tag+"_terrain_"+str(v)+".png")
			if region==3:
				for x in 3:
					var data:=source.get_tile_data(Vector2i(x,0),0)
					var polygon:=data.get_collision_polygon_points(0,0)
					for i in polygon.size():
						if is_equal_approx(polygon[i].y,-10):polygon[i].y=-6
					data.set_collision_polygon_points(0,0,polygon)
			set.add_source(source,100+v)
		map.tile_set=set
		var cells: Array[Vector2i]=map.get_used_cells(0) if map is TileMap else map.get_used_cells()
		for cell in cells:
			var coords: Vector2i=map.get_cell_atlas_coords(0,cell) if map is TileMap else map.get_cell_atlas_coords(cell)
			var id:=100+posmod(cell.x*7+cell.y*11,3)
			if map is TileMap:map.set_cell(0,cell,id,coords)
			else:map.set_cell(cell,id,coords)
		map.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	# Rebuild retained draw commands after the local floor openings are configured.
	level.get_node("RegionalScenery").queue_redraw()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():return
	time+=delta
	for i in glow.size():
		var value:=0.95+0.05*sin(time*1.2+float(i)*1.4)
		glow[i].self_modulate=Color(value,value,value,1)

func _draw() -> void:
	# Pixel links attach each lantern to a ceiling bracket; there is no new collision.
	if region==2:
		# Snow-capped fence on the reunion bank: background depth, never an obstacle.
		for x in [936,976,1016,1056]:
			draw_rect(Rect2(x,490,4,29),Color("415567"))
			draw_rect(Rect2(x,490,4,2),Color("d9edf0"))
			if x<1056:
				draw_rect(Rect2(x+4,501,36,2),Color("768c99"))
				draw_rect(Rect2(x+4,508,36,2),Color("768c99"))
		return
	if region not in [3,4]:return
	var dark:=Color("302d50") if region==3 else Color("634454")
	var metal:=Color("9b96b6") if region==3 else Color("c5a67a")
	for lamp in glow:
		var used:=lamp.texture.get_image().get_used_rect()
		var x:=int(lamp.position.x)
		var end:=int(lamp.position.y+used.position.y-16)
		draw_rect(Rect2(x-7,0,14,7),dark)
		draw_rect(Rect2(x-5,0,10,3),metal)
		for y in range(6,end,6):
			draw_rect(Rect2(x-2,y,4,5),dark)
			draw_rect(Rect2(x-1,y,2,4),metal)
			draw_rect(Rect2(x,y+1,1,2),dark)
