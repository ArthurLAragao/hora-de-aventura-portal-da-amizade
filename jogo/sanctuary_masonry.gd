extends Node2D
## Decorative volumes only. All walking surfaces, bodies and trigger shapes stay in place.
const ENV="res://Assets/02_Environments/06_friendship_portal/tiles/"
const TOP=preload(ENV+"top.png")
const FILL=preload(ENV+"fill.png")
var level: Node2D
var last_stage:=-1
func _ready() -> void:
	level=get_parent()
	z_index=-1
	level.get_node("Terrain").self_modulate.a=0.0
	for n in ["TunnelRoof","FirstSignalStep","SignalTakeoff","ClueShelf"]:
		for v in level.get_node(n).get_children():
			if v is CanvasItem and not v is CollisionShape2D:v.hide()
	for entry in ["LeftEntry","RightEntry"]:level.tunnel.get_node(entry+"/Marker").hide()
	queue_redraw()
func _process(_dt: float) -> void:
	if last_stage!=level.stage:last_stage=level.stage;queue_redraw()
func _surface(x: float,y: float,width: int) -> void:
	for dx in range(0,width,32):
		var w:=mini(32,width-dx)
		draw_texture_rect_region(TOP,Rect2(x+dx,y-1,w,12),Rect2(0,16,w,12))
func _mass(x: float,y: float,width: int,depth: int) -> void:
	# Large broken faces below the native moss lip: no uniform brick grid.
	draw_rect(Rect2(x,y,width,depth),Color("233f55"))
	for dx in range(0,width,48):
		var n:=int(x+dx)/16
		var w:=mini(48,width-dx)
		var bend:=mini(w-8,6+n%4*3)
		var bottom:=minf(depth,72+n%5*19)
		var left:=x+dx
		var face:=PackedVector2Array([Vector2(left,y+20),Vector2(left+w,y+20),Vector2(left+w-4,y+bottom-16),Vector2(left+bend,y+bottom),Vector2(left+3,y+45)])
		draw_colored_polygon(face,Color("345666") if n%2==0 else Color("2b4b5f"))
		draw_polyline(PackedVector2Array([Vector2(left+4,y+30),Vector2(left+bend,y+50),Vector2(left+bend+2,y+bottom-10)]),Color("426e78"),2)
		for row in range(40,int(bottom)-8,22):
			var inset:=6+(n+row)%9
			draw_line(Vector2(left+inset,y+row),Vector2(left+w-7,y+row-3),Color("284453"),2)
		# Small native-scale mineral edges, deliberately staggered.
		draw_rect(Rect2(left+12,y+34+n%3*6,6,2),Color("6b9692"))
		draw_rect(Rect2(left+22,y+40+n%3*6,4,2),Color("4d7c82"))
	for dx in range(0,width,32):
		draw_texture_rect_region(FILL,Rect2(x+dx,y+9,mini(32,width-dx),22),Rect2(0,0,mini(32,width-dx),22))
	_surface(x,y,width)
func _island(x: float,y: float,width: int,depth: int) -> void:
	var p:=PackedVector2Array([Vector2(x,y+6),Vector2(x+width,y+6),Vector2(x+width-5,y+depth-8),Vector2(x+width-20,y+depth-4),Vector2(x+width*0.52,y+depth+8),Vector2(x+12,y+depth-5)])
	draw_colored_polygon(p,Color("203c50"))
	draw_colored_polygon(PackedVector2Array([Vector2(x+3,y+10),Vector2(x+width-3,y+10),Vector2(x+width-10,y+depth-11),Vector2(x+width*0.5,y+depth+3),Vector2(x+13,y+depth-10)]),Color("365e6c"))
	for dx in range(8,width-8,16):
		var d:=depth-12-(dx%3)*3
		draw_polyline(PackedVector2Array([Vector2(x+dx,y+11),Vector2(x+dx+2,y+20),Vector2(x+dx-4,y+d)]),Color("527d80"),2)
		draw_rect(Rect2(x+dx+3,y+14,5,2),Color("74a29c"))
	for dx in range(0,width,32):draw_texture_rect_region(FILL,Rect2(x+dx,y+9,mini(32,width-dx),12),Rect2(0,0,mini(32,width-dx),12))
	_surface(x,y,width)
func _draw() -> void:
	if level==null:return
	# Main banks keep their exact surfaces and vertical edges. Relief is below the path.
	_mass(0,level.LEFT_FLOOR,448,176)
	_mass(608,level.FLOOR,768,208)
	# The elevated signal surfaces become small islands, without moving their colliders.
	if level.stage==2:
		_island(16,level.LEFT_FLOOR-48,64,29)
		_island(128,level.LEFT_FLOOR-96,64,37)
		_island(368,level.LEFT_FLOOR-96,96,44)
	var y: float=level.FLOOR
	# Cutaway channel: the rear wall is behind Cake and the entire free height is readable.
	draw_rect(Rect2(832,y-22.35,160,22.35),Color("182f40"))
	for x in range(840,992,24):draw_line(Vector2(x,y-13),Vector2(x+12,y-13),Color("2c4b5d"),1)
	_mass(832,y-80,160,57)
	# Real material corners stop exactly at the physical ceiling, never across the opening.
	for x in [832,984]:
		draw_rect(Rect2(x,y-72,8,49),Color("244659"))
		draw_line(Vector2(x+2,y-67),Vector2(x+2,y-26),Color("668e91"),2)
	draw_line(Vector2(832,y-23),Vector2(992,y-23),Color("1a3041"),2)
	draw_line(Vector2(832,y-1),Vector2(992,y-1),Color("789c98"),1)
	# Small masonry shoes integrate the contextual switch with the same architecture.
	draw_rect(Rect2(1028,y-3,24,4),Color("2a4556"))
