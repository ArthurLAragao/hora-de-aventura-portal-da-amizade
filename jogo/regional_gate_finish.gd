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
	var stone:=region==3
	var dark:=Color("29253e") if stone else Color("603a49")
	var body:=Color("605b7b") if stone else Color("b67c5e")
	var shine:=Color("a2a3c5") if stone else Color("f4d194")
	var inset:=Color("38324e") if stone else Color("80534b")
	var accent:=Color("8fc9d1") if stone else Color("9bc3a2")
	var x:=int(box.position.x);var y:=int(box.position.y)
	var w:=int(box.size.x);var h:=int(box.size.y)
	# Recessed threshold and stepped lintel preserve the exact useful opening.
	draw_rect(Rect2(x-9,y-10,w+18,10),dark)
	draw_rect(Rect2(x-7,y-8,w+14,5),body)
	draw_rect(Rect2(x-5,y-8,w+10,1),shine)
	for px in [x-7,x+w]:
		draw_rect(Rect2(px,y-1,7,h+5),dark)
		draw_rect(Rect2(px+1,y,5,h+2),body)
		draw_rect(Rect2(px+1,y,1,h),shine)
		for py in range(y+8,y+h,12):
			draw_rect(Rect2(px+1,py,5,2),inset)
			if not stone:draw_rect(Rect2(px+3,py-3,2,2),shine)
	draw_rect(Rect2(x-8,y+h, w+16,3),dark)
	if not previous:
		draw_rect(box,dark)
		for px in range(x+2,x+w-2,8):
			draw_rect(Rect2(px,y+2,6,h-4),body)
			draw_rect(Rect2(px,y+2,1,h-4),shine.darkened(0.25))
			draw_rect(Rect2(px+4,y+3,2,h-6),inset)
		for py in [y+10,y+h-14]:
			draw_rect(Rect2(x+1,py,w-2,6),dark)
			draw_rect(Rect2(x+3,py+1,w-6,3),shine.darkened(0.18))
			for px in range(x+5,x+w-4,12):draw_rect(Rect2(px,py+2,2,2),dark)
		var cx:=x+w/2;var cy:=y+h/2
		draw_rect(Rect2(cx-6,cy-7,12,14),dark)
		draw_rect(Rect2(cx-4,cy-5,8,10),body)
		if stone:
			draw_rect(Rect2(cx-1,cy-4,2,8),accent)
			draw_rect(Rect2(cx-3,cy-1,6,2),accent)
		else:
			draw_rect(Rect2(cx-3,cy-3,6,6),shine)
			draw_rect(Rect2(cx-1,cy-2,2,4),dark)
	else:
		# Folded leaf and two exposed latch pins make the open state unambiguous.
		draw_rect(Rect2(x,y-6,w,6),body)
		draw_rect(Rect2(x+1,y-5,w-2,2),shine)
		for px in [x-5,x+w+1]:
			draw_rect(Rect2(px,y+2,4,8),dark)
			draw_rect(Rect2(px+1,y+3,2,5),accent)
