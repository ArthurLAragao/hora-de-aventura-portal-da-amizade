extends Control
## Relicário compartilhado pela HUD e pelo monumento; cristais preenchem todo o encaixe.
const COLORS=[Color("79d9ef"),Color("87ddaa"),Color("c497f1"),Color("f4b47d"),Color("f0a8ce"),Color("ead281")]
var acquired: Array=[]
var pulses: Dictionary={}
var clock:=0.0
var compact:=true
func _ready() -> void:mouse_filter=MOUSE_FILTER_IGNORE
func set_crystals(values: Array) -> void:
	for n in values:
		if not n in acquired:pulses[n]=1.0
	acquired=values.duplicate();queue_redraw()
func _process(delta: float) -> void:
	clock+=delta
	for n in pulses.keys():pulses[n]=maxf(0,pulses[n]-delta*0.8)
	queue_redraw()
func facet(at: Vector2,r: float) -> PackedVector2Array:
	return PackedVector2Array([at+Vector2(0,-r),at+Vector2(r*0.64,-r*0.34),at+Vector2(r*0.52,r*0.6),at+Vector2(0,r),at+Vector2(-r*0.52,r*0.6),at+Vector2(-r*0.64,-r*0.34)])
func _draw() -> void:
	var r:=15.0 if compact else 24.0
	for i in 6:
		var at:=Vector2(24+i*42,24) if compact else Vector2(70+cos(TAU*i/6-PI/2)*52,70+sin(TAU*i/6-PI/2)*52)
		var lit: bool=i+1 in acquired
		var pulse: float=pulses.get(i+1,0.0)
		if compact and i<5:draw_line(at+Vector2(12,0),at+Vector2(30,0),Color("857353"),3)
		draw_circle(at,r+5,COLORS[i].darkened(0.54) if lit else Color("192f3a"));draw_arc(at,r+5,0,TAU,24,Color("a88d5e"),2)
		if lit:draw_circle(at,r+5+5*pulse,Color(COLORS[i],0.07+0.06*sin(clock*1.8+i)+0.16*pulse))
		var points:=facet(at,r)
		draw_colored_polygon(points,COLORS[i] if lit else Color("304751"))
		draw_polyline(points+PackedVector2Array([points[0]]),Color("f6e8b6") if lit else Color("6a7d7d"),1)
		if lit:
			draw_colored_polygon(PackedVector2Array([points[0],at,points[4],points[5]]),COLORS[i].lightened(0.20))
			draw_colored_polygon(PackedVector2Array([at,points[1],points[2],points[3]]),COLORS[i].darkened(0.20))
			draw_line(at+Vector2(-3,-r*0.5),at+Vector2(-3,r*0.28),Color("fffae1"),2)
			var shine:=at+Vector2(8*sin(clock*0.6+i),-r-4)
			draw_line(shine-Vector2(2,0),shine+Vector2(2,0),Color("ffecbc"),1)
			draw_line(shine-Vector2(0,2),shine+Vector2(0,2),Color("ffecbc"),1)
