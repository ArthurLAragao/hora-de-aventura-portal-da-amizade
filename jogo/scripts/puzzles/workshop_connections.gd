extends Node2D
## Circuito espacial da oficina: três cotovelos, quatro posições e ligação final por BMO.
const ART="res://Assets/03_Objects_and_Puzzles/pixel_refinement/"
const SOCKETS=[Vector2(1432,354),Vector2(1520,284),Vector2(1216,308)]
var turns: Array[int]=[1,3,2]
var areas: Array[Area2D]=[]
var indicators: Array[Label]=[]
var locked:=false
var root_level: Node2D
var _art_state:=-1

## Reutiliza os alojamentos existentes; os patamares existentes guiam a visita aos três encaixes.
func _ready() -> void:
	root_level=get_parent();texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	for at in SOCKETS:
		var housing:=Sprite2D.new();housing.texture=load(ART+"candy_circuit_housing.png")
		housing.position=at;housing.show_behind_parent=true;add_child(housing)
		var area:=Area2D.new();area.position=at;area.collision_layer=0;area.collision_mask=2
		var shape:=CollisionShape2D.new();var rect:=RectangleShape2D.new();rect.size=Vector2(68,70)
		shape.shape=rect;area.add_child(shape)
		var prompt:=Label.new();prompt.position=Vector2(-24,-72);prompt.add_theme_font_size_override("font_size",14)
		prompt.add_theme_constant_override("outline_size",3);area.add_child(prompt)
		indicators.append(prompt);add_child(area);areas.append(area)
	_sync_art()

## A continuidade da rota física corresponde exatamente às posições resolvidas.
func solved() -> bool:return turns==[0,0,0]

## Uma entrada escolhe apenas o encaixe mais próximo; o terminal reserva o circuito ao ligar.
func _process(_delta: float) -> void:
	for indicator in indicators:indicator.text=""
	if root_level.energy_terminal.energized:locked=true
	if locked or root_level.energy_terminal.pending:_sync_art();return
	for actor in [root_level.finn,root_level.bmo]:
		if not actor.has_ability(&"lever") or actor.movement_locked:continue
		var nearest:=-1;var distance:=INF
		for i in areas.size():
			if not areas[i].overlaps_body(actor):continue
			var candidate: float=actor.global_position.distance_squared_to(areas[i].global_position)
			if candidate<distance:nearest=i;distance=candidate
		if nearest<0:continue
		indicators[nearest].text=("E" if actor.player_id==1 else "Enter")+": girar"
		if Input.is_action_just_pressed(actor.get_interact_action()):turns[nearest]=posmod(turns[nearest]+1,4)
	_sync_art()

## Redesenha somente ao girar uma peça ou energizar o circuito.
func _sync_art() -> void:
	var state:=turns[0]+turns[1]*4+turns[2]*16+(64 if locked else 0)
	if state==_art_state:return
	_art_state=state;queue_redraw()

## Desenha cobre com contorno e luz; a mesma linha mostra a conexão real entre encaixes.
func conduit(points: PackedVector2Array,powered: bool) -> void:
	draw_polyline(points,Color("493b50"),10)
	draw_polyline(points,Color("b48058"),6)
	draw_polyline(points,Color("fff0b0") if powered else Color("e4b57a"),2)

## Integra fonte, cotovelos e receptor sem processar imagens durante a execução.
func _draw() -> void:
	conduit(PackedVector2Array([Vector2(1360,366),Vector2(1216,366),Vector2(1216,332)]),locked)
	conduit(PackedVector2Array([Vector2(1240,308),Vector2(1340,308),Vector2(1340,354),Vector2(1408,354)]),locked)
	conduit(PackedVector2Array([Vector2(1432,330),Vector2(1432,284),Vector2(1496,284)]),locked)
	conduit(PackedVector2Array([Vector2(1520,308),Vector2(1520,312),Vector2(1576,312),Vector2(1576,366)]),locked)
	for i in 3:
		var points:=PackedVector2Array([Vector2(-24,0),Vector2.ZERO,Vector2(0,-24 if i==0 else 24)])
		if i==2:points=PackedVector2Array([Vector2(0,24),Vector2.ZERO,Vector2(24,0)])
		for k in points.size():points[k]=points[k].rotated(turns[i]*PI*0.5).round()+SOCKETS[i]
		conduit(points,locked)
		draw_rect(Rect2(SOCKETS[i]-Vector2(4,4),Vector2(8,8)),Color("493b50"))
		draw_rect(Rect2(SOCKETS[i]-Vector2(2,2),Vector2(4,4)),Color("f4d79c"))
