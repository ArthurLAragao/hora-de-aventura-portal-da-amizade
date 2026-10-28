@tool
extends Node2D
## Exterior raster preserved. Interior and three socket lights use its pixel palette.
const ART=preload("res://Assets/03_Objects_and_Puzzles/sprites/portal_sanctuary_v2.png")
const REGION=Rect2(90,195,1022,960)
# The aperture overlaps the opaque INNER edge by 1–2 local pixels; ART is drawn on top.
# Bounds measured from the preserved raster alpha, including its wider springline.
var OPENING=PackedVector2Array([Vector2(-20,-6),Vector2(-20,-44),Vector2(-18,-49),Vector2(-14,-55),Vector2(-8,-59),Vector2(0,-61),Vector2(8,-59),Vector2(14,-55),Vector2(19,-49),Vector2(21,-44),Vector2(20,-6)])
var texture: Texture2D:
	set(value):texture=value;queue_redraw()
var repairs: Array=[false,false,false]:
	set(value):
		for i in 3:
			if value[i] and not repairs[i]:ignition[i]=0.65
		repairs=value.duplicate();queue_redraw()
var ignition: Array[float]=[0.0,0.0,0.0]
var clock:=0.0
var _frame:=-1
var _aperture_cells: Array[Vector2]=[]
var _wave_phase: Array[float]=[]
var _wave_radius: Array[float]=[]
## Calcula uma única vez as células internas da abertura e os coeficientes fixos da onda.
func _init() -> void:
	for y in range(-61,-6):
		for x in range(-20,21):
			var cell:=Vector2(x,y)
			if not [cell,cell+Vector2.RIGHT,cell+Vector2.DOWN,cell+Vector2.ONE].all(func(p):return Geometry2D.is_point_in_polygon(p,OPENING)):continue
			var v:=Vector2(x,(y+32)*0.65)
			_aperture_cells.append(cell)
			_wave_radius.append(v.length())
			_wave_phase.append(v.length()*0.65-atan2(v.y,v.x)*2.0)
## Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: portal, interior animado e três luzes de reparo.
func _process(dt: float) -> void:
	clock+=dt
	for i in 3:ignition[i]=maxf(0.0,ignition[i]-dt)
	var frame:=int(clock*12)
	if frame!=_frame:_frame=frame;queue_redraw()
## Retorna uma cópia do estado das três luzes, sem permitir modificar o progresso por referência.
func light_states() -> Array:
	return repairs.duplicate()
## Desenha a peça octogonal usada nas luzes do portal.
func _octagon(center: Vector2,r: float,color: Color) -> void:
	var p:=PackedVector2Array()
	for v in [Vector2(-0.5,-1),Vector2(0.5,-1),Vector2(1,-0.5),Vector2(1,0.5),Vector2(0.5,1),Vector2(-0.5,1),Vector2(-1,0.5),Vector2(-1,-0.5)]:p.append(center+v*r)
	draw_colored_polygon(p,color)
## Desenha a apresentação local; este método não concede progresso nem altera colisões. Contexto: portal, interior animado e três luzes de reparo.
func _draw() -> void:
	var active:=repairs.all(func(v):return v)
	var partial:=repairs.any(func(v):return v)
	draw_colored_polygon(OPENING,Color("193b50") if partial else Color("152b3a"))
	if active:
		# Integer local cells (2 world pixels). Every corner stays inside the aperture.
		# Broad flowing bands replace the old rectangular, independently scaled effect.
		for i in _aperture_cells.size():
			var wave:=sin(_wave_phase[i]-clock*1.1)
			var color:=Color("27586c")
			if wave>0.5:color=Color("68aba8")
			elif wave>0.0:color=Color("40858c")
			if wave>0.95 and _wave_radius[i]>9:color=Color("a0d5bd")
			draw_rect(Rect2(_aperture_cells[i],Vector2.ONE),color)
	var height:=80.0*REGION.size.y/REGION.size.x
	draw_texture_rect_region(ART,Rect2(-40,-height,80,height),REGION,Color.WHITE if repairs[0] else Color(0.70,0.76,0.85))
	for i in 3:
		var c:=Vector2([-15,0,15][i],[-61,-67,-61][i])
		_octagon(c,5,Color("223545"))
		_octagon(c,4,Color("927c50"))
		_octagon(c,3,Color("172f42"))
		if repairs[i]:
			_octagon(c,2.5,Color("70bda9"))
			draw_rect(Rect2(c+Vector2(-1,-2),Vector2(2,3)),Color("e2e5aa"))
			if ignition[i]>0:
				draw_line(c+Vector2(-3,-4),c+Vector2(3,-4),Color("d6d794"),1)
		else:
			draw_line(c+Vector2(-2,1),c+Vector2(2,1),Color("426474"),1)
