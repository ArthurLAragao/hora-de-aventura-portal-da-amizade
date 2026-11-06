@tool
extends Node2D
## Decorative vegetation and construction details, drawn on an integer pixel grid.
var region := 2
var floor_y := 519.0
var elapsed := 0.0

func _process(delta: float) -> void:
	if Engine.is_editor_hint():return
	elapsed+=delta
	# Discrete two-pixel leaf motion; roots and all physics remain stationary.
	if int(elapsed*3)!=int((elapsed-delta)*3):queue_redraw()

func sprig(x: int,y: int,height: int,phase: float) -> void:
	var dark:=Color("244b68") if region==2 else (Color("303c58") if region==3 else Color("395953"))
	var mid:=Color("78a9b6") if region==2 else (Color("438785") if region==3 else Color("5e9279"))
	var tip:=Color("d2edef") if region==2 else (Color("83c4b0") if region==3 else Color("bed193"))
	var sway:=int(round(sin(elapsed*0.7+phase)))
	draw_rect(Rect2(x,y-height,2,height),dark)
	for k in range(3,height-2,6):
		var side:=1 if k%12<6 else -1
		var lx:=x+side*3+sway
		draw_rect(Rect2(lx-2,y-k-3,6,4),dark)
		draw_rect(Rect2(lx-1,y-k-3,4,2),mid)
		draw_rect(Rect2(lx,y-k-3,2,1),tip)

func _draw() -> void:
	var beds: Array
	if region==2:beds=[40,192,1008,1200,1816,2224]
	elif region==3:beds=[48,384,912,1152,1760,2112]
	else:beds=[192,928,1816,2144]
	for x in beds:
		var base:=int(floor_y)
		if region==4:
			# Small herb planters belong to the workshop, not to the playable terrain.
			draw_rect(Rect2(x-12,base-10,28,10),Color("683f50"))
			draw_rect(Rect2(x-10,base-8,24,7),Color("b57665"))
			draw_rect(Rect2(x-14,base-12,32,4),Color("edc78c"))
			base-=12
		for i in 5:sprig(x+i*4-6,base,12+(i*7)%19,float(x+i))
		if region==3:
			for i in 3:
				draw_rect(Rect2(x+22+i*4,base-5-i%2*3,2,5+i%2*3),Color("87bcb1"))
	# Framed masonry under the existing solid banks breaks up monotonous tile strips.
	if region==4:
		for x in [32,224,896,1152,1376,1760,2080]:
			draw_rect(Rect2(x,408,12,108),Color("7c4058"))
			draw_rect(Rect2(x+2,408,3,106),Color("c57888"))
			for y in [410,450,490]:draw_rect(Rect2(x-2,y,16,4),Color("e4a0a5"))
	elif region==3:
		for x in [96,320,896,1120,1408,1760,2048]:
			for i in 4:
				draw_rect(Rect2(x+i*4,420+i*8,4,10),Color("3f365d"))
	# A continuous tunnel reveal stays behind Cake, respecting the original clearance.
	if region==2:
		for x in [444,608]:
			draw_rect(Rect2(x,476,4,42),Color("325d87"))
			draw_rect(Rect2(x+1,480,2,36),Color("76a9c5"))
		for x in range(448,608,16):
			draw_rect(Rect2(x,495,15,3),Color("183f67"))
			draw_rect(Rect2(x,498,2,3),Color("527e9e"))
