@tool
extends Node2D
## Local pixel-grid presentation for existing gates. No collision or progression logic.
var gate: CoopGate
var region := 3
var box := Rect2()
var previous := false

func _ready() -> void:
	gate=get_parent() as CoopGate
	var shape:=gate.get_node("CollisionShape2D") as CollisionShape2D
	var size: Vector2=shape.shape.size
	box=Rect2(shape.position-size*0.5,size)
	z_index=1
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	gate.get_node("Sprite2D").hide()
	queue_redraw()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():return
	if is_instance_valid(gate) and previous!=gate.is_open:
		previous=gate.is_open
		queue_redraw()

func _draw() -> void:
	if gate==null:return
	var outline:=Color("302b4d") if region==3 else Color("65394c")
	var material:=Color("6e6488") if region==3 else Color("b97c64")
	var light:=Color("afa7c9") if region==3 else Color("f4ce92")
	var accent:=Color("7ed7d8") if region==3 else Color("94c3aa")
	var x:=floorf(box.position.x);var y:=floorf(box.position.y)
	var w:=floorf(box.size.x);var h:=floorf(box.size.y)
	# Posts sit just outside the useful opening; the closed leaf matches its collider.
	for px in [x-6,x+w]:
		draw_rect(Rect2(px,y-4,6,h+8),outline)
		draw_rect(Rect2(px+1,y-2,4,h+4),material)
		draw_rect(Rect2(px+1,y-2,1,h+4),light)
		for py in range(int(y)+8,int(y+h),16):draw_rect(Rect2(px+1,py,4,2),outline)
	draw_rect(Rect2(x-7,y-7,w+14,7),outline)
	draw_rect(Rect2(x-5,y-5,w+10,3),light)
	if not previous:
		draw_rect(box,outline)
		for px in range(int(x)+2,int(x+w)-2,8):
			draw_rect(Rect2(px,y+2,6,h-4),material)
			draw_rect(Rect2(px,y+2,2,h-4),light.darkened(0.18))
		for py in [y+10,y+h-14]:
			draw_rect(Rect2(x+1,py,w-2,5),outline)
			draw_rect(Rect2(x+3,py+1,w-6,2),accent.darkened(0.25))
		draw_rect(Rect2(x+w*0.5-4,y+h*0.5-4,8,8),outline)
		draw_rect(Rect2(x+w*0.5-2,y+h*0.5-2,4,4),accent)
	else:
		# A compact lifted leaf leaves the entire opening visibly clear.
		draw_rect(Rect2(x,y-4,w,4),material)
		for px in [x-5,x+w+1]:
			draw_rect(Rect2(px,y+2,4,8),outline)
			draw_rect(Rect2(px+1,y+3,2,5),accent)
