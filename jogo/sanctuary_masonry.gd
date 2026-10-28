@tool
extends Node2D
## Raster pixel material replaces the flat facets. Physics remains in the original nodes.
const PIXELS=preload("res://pixel_environment.gd")
const ENV="res://Assets/02_Environments/06_friendship_portal/"
const TOP=preload(ENV+"tiles/top.png")
var rock: Texture2D
var fringe: Texture2D
var level: Node2D
var last_stage:=-1
func _ready() -> void:
	level=get_parent()
	z_index=-1
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	texture_repeat=CanvasItem.TEXTURE_REPEAT_MIRROR
	rock=PIXELS.texture(ENV+"rock_fill_v3.png",64)
	fringe=PIXELS.texture(ENV+"moss_fringe_v3.png",128)
	level.get_node("Terrain").self_modulate.a=0.0
	for n in ["TunnelRoof","FirstSignalStep","SignalTakeoff","ClueShelf"]:
		for v in level.get_node(n).get_children():
			if v is CanvasItem and not v is CollisionShape2D:v.hide()
	for entry in ["LeftEntry","RightEntry"]:level.tunnel.get_node(entry+"/Marker").hide()
	queue_redraw()
func _process(_dt: float) -> void:
	if level!=null and last_stage!=level.stage:last_stage=level.stage;queue_redraw()
func _surface(x: float,y: float,width: int) -> void:
	for dx in range(0,width,32):
		var w:=mini(32,width-dx)
		draw_texture_rect_region(TOP,Rect2(x+dx,y-1,w,12),Rect2(0,16,w,12))
func _rock_polygon(points: PackedVector2Array,tint: Color=Color.WHITE) -> void:
	var uv:=PackedVector2Array()
	for point in points:uv.append(point/128.0)
	draw_colored_polygon(points,tint,uv,rock)
func _roots(x: float,y: float,width: int) -> void:
	# Root fringe lies inside the terrain face, never in Cake's free passage.
	for dx in range(0,width,128):
		var w:=mini(128,width-dx)
		draw_texture_rect_region(fringe,Rect2(x+dx,y,w,fringe.get_height()),Rect2(0,0,w,fringe.get_height()))
func _mass(x: float,y: float,width: int,depth: int) -> void:
	_rock_polygon(PackedVector2Array([Vector2(x,y),Vector2(x+width,y),Vector2(x+width,y+depth),Vector2(x,y+depth)]),Color("a9bec9"))
	_roots(x,y+7,width)
	_surface(x,y,width)
func _island(x: float,y: float,width: int,depth: int) -> void:
	# Stepped pixel edge, not a smooth vector triangle. Top and body are unchanged.
	var p:=PackedVector2Array([Vector2(x,y+6),Vector2(x+width,y+6),Vector2(x+width,y+18),Vector2(x+width-4,y+18),Vector2(x+width-4,y+28),Vector2(x+width-12,y+28),Vector2(x+width-12,y+depth-4),Vector2(x+width-24,y+depth-4),Vector2(x+width-24,y+depth+4),Vector2(x+24,y+depth+4),Vector2(x+24,y+depth-4),Vector2(x+12,y+depth-4),Vector2(x+12,y+22),Vector2(x+4,y+22),Vector2(x+4,y+12),Vector2(x,y+12)])
	_rock_polygon(p)
	_roots(x,y+7,width)
	_surface(x,y,width)
func _draw() -> void:
	if level==null or rock==null:return
	_mass(0,level.LEFT_FLOOR,448,176)
	_mass(608,level.FLOOR,768,208)
	if level.stage==2:
		_island(16,level.LEFT_FLOOR-48,64,32)
		_island(128,level.LEFT_FLOOR-96,64,38)
		_island(368,level.LEFT_FLOOR-96,96,44)
	var y: float=level.FLOOR
	# Darker rear material, so the white/orange crawling sprite remains readable.
	_rock_polygon(PackedVector2Array([Vector2(832,y-22.35),Vector2(992,y-22.35),Vector2(992,y),Vector2(832,y)]),Color("3c586e"))
	_mass(832,y-80,160,57)
	# Texture-backed end stones make a continuous lintel. No columns across the opening.
	for x in [832,984]:
		draw_line(Vector2(x+1,y-68),Vector2(x+1,y-24),Color("6e9296"),1)
		draw_line(Vector2(x+7,y-68),Vector2(x+7,y-24),Color("182f40"),1)
	draw_line(Vector2(832,y-23),Vector2(992,y-23),Color("14293b"),2)
	draw_line(Vector2(832,y-1),Vector2(992,y-1),Color("789c98"),1)
	draw_rect(Rect2(1028,y-3,24,4),Color("2a4556"))
