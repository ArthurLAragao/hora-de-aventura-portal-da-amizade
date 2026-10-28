@tool
extends Node2D
## Environment-only composition. Physics and puzzle state remain in the level.
@export_enum("Reino Gelado:2","Caverna Musical:3","Oficina Doce:4") var region: int = 2
var level: Node2D
var env: String
var tunnel_wall_texture: Texture2D
var underside_texture: Texture2D
var floor_y := 388.0
var motes: Array[Sprite2D] = []
var lamps: Array[Sprite2D] = []
var elapsed := 0.0

func _ready() -> void:
	level=get_parent()
	env="res://Assets/02_Environments/"+{2:"02_ice_kingdom",3:"03_musical_cave",4:"04_candy_workshop"}[region]+"/tiles/"
	underside_texture=load(env+"bottom.png")
	if region==2:tunnel_wall_texture=load("res://Assets/02_Environments/regional_refinement/ice_tunnel_wall_detail.png")
	floor_y=519.0 if region==2 else 388.0
	z_index=-1
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	# Composed layers replace the earlier scatter; original helper methods remain available.
	process_priority=10
	_configure_presentation.call_deferred()
	_add_finish.call_deferred()
	queue_redraw()

func prop(file: String,x: float,y: float,scale_factor: float=1.0,tint: Color=Color.WHITE,plane: int=-1,flip: bool=false) -> Sprite2D:
	var tex:=load(env+file+".png") as Texture2D
	var used:=tex.get_image().get_used_rect()
	var s:=Sprite2D.new()
	s.name=file+"_%d_%d"%[int(x),get_child_count()]
	s.texture=tex;s.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	s.scale=Vector2.ONE*scale_factor
	s.position=Vector2(x,y-(used.end.y-tex.get_height()*0.5)*scale_factor)
	s.z_index=plane;s.modulate=tint;s.flip_h=flip
	s.set_meta("ground_y",y)
	add_child(s)
	return s

func _ice() -> void:
	# Distinct ice groves frame the safe start, machinery, bridge and final clearing.
	for spec in [[36,3],[208,2],[1010,2],[1180,3],[1364,2],[1820,3],[2028,2],[2284,3]]:
		prop("decor_03",spec[0],floor_y,spec[1],Color("a6d5e5"),-3)
	for spec in [[80,2],[250,2],[720,1],[1050,2],[1240,1],[1320,2],[1780,2],[1880,1],[2180,2],[2260,1]]:
		prop("decor_02",spec[0],floor_y,spec[1],Color("c4e4ed"),-2)
	for x in [30,168,264,686,988,1144,1292,1772,1974,2050,2272]:
		prop("decor_04",x,floor_y,1.0,Color.WHITE,0)
	# Tunnel face uses the same ice as the surrounding banks, with a cutaway interior.
	for x in [62,222,1090,1332,1848,2220]:
		prop("pillar",x,floor_y,2.0,Color("88b6d2"),-4)

func _cave() -> void:
	# Crystal chambers alternate between low groups and tall distant formations.
	for spec in [[32,3],[180,2],[408,3],[886,2],[1168,3],[1372,2],[1772,3],[2116,2]]:
		prop("decor_04",spec[0],floor_y,spec[1],Color("a4a4c6"),-4)
	for spec in [[76,2],[352,2],[880,2],[1144,1],[1424,2],[1704,2],[2016,2]]:
		prop("decor_01",spec[0],floor_y,spec[1],Color("c3b3d4"),-2)
	for spec in [[132,1],[460,1],[932,1],[1184,1],[1350,1],[1808,1],[2160,1]]:
		lamps.append(prop("decor_02",spec[0],floor_y,spec[1],Color.WHITE,-1))
	for x in [44,304,920,1192,1400,1776,2150]:
		var stalactite:=prop("decor_03",x,96,2.0,Color("65628d"),-5)
		stalactite.flip_v=true
		stalactite.position.y=70
	for x in [90,416,896,1392,1784,2160]:
		prop("pillar",x,floor_y,2.0,Color("5c607c"),-5)

func _workshop() -> void:
	# Framed workshop bays: transport, checkpoint, energy, then the exit alcove.
	for x in [36,244,904,1160,1744,2070,2160]:
		prop("pillar",x,floor_y,2.0,Color("d9b997"),-4)
	for x in [72,268,908,1168,1764,2072]:
		prop("decor_02",x,floor_y,2.0,Color("b6c9b0"),-3)
	for x in [34,892,1760,2152]:
		var gear:=prop("decor_01",x,floor_y-18,2.0,Color("d6b77b"),-2)
		gear.set_meta("gear",true)
	for x in [160,980,1440,1920]:
		var lamp:=prop("decor_04",x,210,2.0,Color.WHITE,-3)
		lamps.append(lamp)
	for x in [86,958,1790,2164]:
		prop("decor_03",x,floor_y,2.0,Color("ead5bd"),-2)

func _draw() -> void:
	if level==null:return
	if region==2:
		draw_rect(Rect2(645,501,6,18),Color("25435c"))
		draw_rect(Rect2(647,503,2,14),Color("a4c2cd"))
		draw_rect(Rect2(636,516,24,3),Color("7195a8"))
		for x in [432,624]:
			draw_rect(Rect2(x-9,416,3,103),Color("3d6278"))
			draw_rect(Rect2(x-9,416,11,3),Color("9db8c4"))
		# Detailed cutaway: rear ice strata, arch ribs and floor reveal, behind Cake.
		var wall:=tunnel_wall_texture
		for x in range(448,608,32):
			draw_texture_rect_region(wall,Rect2(x,497,32,22),Rect2(0,4,32,22),Color("b0c1d5"))
		for x in range(448,609,32):
			draw_rect(Rect2(x,496,3,23),Color("173d62"))
			draw_rect(Rect2(x+1,498,1,17),Color("6ca2bb"))
			draw_rect(Rect2(x+3,497,5,2),Color("375f80"))
		for x in [446,606]:
			draw_rect(Rect2(x,493,4,26),Color("1c4265"))
			draw_rect(Rect2(x,493,8,3),Color("a5d8e5"))
			draw_rect(Rect2(x,516,8,3),Color("6d9bb8"))
		draw_rect(Rect2(448,517,160,2),Color("accbd7"))
		for x in range(0,2304,32):
			if level.get_node("Terrain").get_cell_source_id(0,Vector2i(x/32,16))<0:continue
			draw_texture_rect(underside_texture,Rect2(x,657,32,32),false,Color("91b7d2"))
	elif region==3:
		# Muted veins and darker undersides carry the cave material beneath the path.
		for x in range(0,2176,32):
			if level.get_node("TileMapLayer").get_cell_source_id(Vector2i(x/32,12))<0:continue
			draw_texture_rect(underside_texture,Rect2(x,516,32,32),false,Color("a6a0bc"))
	else:
		# Pipe routes live in the background: they connect bays without suggesting platforms.
		for span in [[24,340],[856,1210],[1360,1870],[1990,2160]]:
			var y:=264.0
			draw_line(Vector2(span[0],y),Vector2(span[1],y),Color("795a62"),12)
			draw_line(Vector2(span[0],y-2),Vector2(span[1],y-2),Color("93a991"),7)
			for x in range(span[0]+8,span[1],48):
				draw_rect(Rect2(x,y-8,4,16),Color("9b8055"))
			for x in [span[0],span[1]]:
				draw_line(Vector2(x,y),Vector2(x,382),Color("795a62"),12)
				draw_line(Vector2(x-2,y),Vector2(x-2,382),Color("93a991"),7)
		for x in [160,980,1440,1920]:draw_line(Vector2(x,160),Vector2(x,187),Color("715560"),2)
		for x in range(0,2176,32):
			if level.get_node("TileMapLayer").get_cell_source_id(Vector2i(x/32,12))<0:continue
			draw_texture_rect(underside_texture,Rect2(x,516,32,32),false,Color("dec7bf"))

func _process(delta: float) -> void:
	if Engine.is_editor_hint():return
	elapsed+=delta
	_context()
	for i in lamps.size():
		var brightness:=0.96+0.04*sin(elapsed*1.3+i*1.7)
		lamps[i].self_modulate=Color(brightness,brightness,brightness)
	if region==4:
		for child in get_children():
			if child.has_meta("gear"):child.rotation=0.0 # Preserve crisp pixel contours.

func _configure_presentation() -> void:
	if Engine.is_editor_hint():return
	if region!=2:return
	for name in ["TunnelHint","GapHint","RoleHint"]:level.get_node(name).hide()
	var text: Label=level.get_node("Instructions/Text")
	text.position=Vector2(16,34);text.size=Vector2(540,44)
	text.add_theme_font_size_override("font_size",16)
	text.add_theme_constant_override("outline_size",2)
	var backplate:=Panel.new();backplate.position=Vector2(6,6);backplate.size=Vector2(570,88)
	var style:=StyleBoxFlat.new();style.bg_color=Color("153a57e8");style.border_color=Color("92d4e3")
	style.set_border_width_all(1);style.set_corner_radius_all(6);backplate.add_theme_stylebox_override("panel",style)
	level.get_node("Instructions").add_child(backplate);level.get_node("Instructions").move_child(backplate,0)
	var title:=Label.new();title.position=Vector2(16,10);title.text="PASSAGEM DO REINO GELADO"
	title.add_theme_font_size_override("font_size",14);level.get_node("Instructions").add_child(title)
	var back:=Button.new();back.text="Fases";back.position=Vector2(1020,12);back.size=Vector2(110,32)
	back.pressed.connect(func():get_tree().change_scene_to_file("res://phase_select.tscn"));level.get_node("Instructions").add_child(back)
	var help:=Button.new();help.text="Controles";help.position=Vector2(900,12);help.size=Vector2(110,32)
	level.get_node("Instructions").add_child(help)
	var panel:=PanelContainer.new();panel.position=Vector2(580,54);panel.hide();level.get_node("Instructions").add_child(panel)
	var keys:=Label.new();keys.text="P1: A/D, Espaço/W, E, Q\nP2: setas, Cima, Enter, Shift direito\nCake: interação no túnel; habilidade na âncora.\nFionna: empurre o bloco e use a manivela.\nEsc: cancelar | F2: reiniciar"
	keys.add_theme_font_size_override("font_size",14);panel.add_child(keys)
	help.pressed.connect(func():panel.visible=not panel.visible)
	level.get_node("FinalHint").hide()

func _context() -> void:
	if region==2 and level.completed:return
	if region==2:
		var cake=level.cake
		var prompt: Label=level.tunnel.prompt
		prompt.text=""
		if cake.crawling:prompt.text="Esquerda/direita: rastejar"
		elif level.tunnel.can_interact(cake):prompt.text=("E" if cake.player_id==1 else "Enter")+": rastejar"
		level.get_node("SwitchHint").visible=absf(cake.position.x-648)<120 and not level.first_unlocked
		for crank in [level.first_crank,level.crank]:
			crank.status.visible=crank.pending or (crank.solved and absf(level.fionna.position.x-crank.position.x)<140)
		level.first_crank.prompt.visible=level.first_unlocked
		var goal: String
		if not level.first_unlocked:goal="Cake: atravesse o túnel. Fionna: use o bloco."
		elif not level.first_crank.solved:goal="Fionna: estenda a primeira passagem."
		elif not level.crank.solved:goal="Cake sustenta; Fionna libera a passagem."
		else:goal="Recuperem o cristal e encontrem-se na saída."
		level.get_node("Instructions/Text").text="Cake P%d • Fionna P%d\n%s"%[cake.player_id,level.fionna.player_id,goal]+(" • INÍCIO DE TESTE" if level.test_start>0 else "")
	else:
		var actors: Array=level.get_node("Players").get_children()
		for name in ["MusicPanel","SymbolTerminal","EnergyTerminal"]:
			var mechanism=level.get_node_or_null(name)
			if mechanism==null:continue
			var status:=mechanism.get_node_or_null("Status") as Label
			if status!=null:status.visible=false

func _add_finish() -> void:
	var details:=Node2D.new()
	details.set_script(load("res://regional_composition.gd"))
	details.name="RegionalComposition"
	details.region=region
	details.floor_y=floor_y
	details.z_index=0
	add_child(details)
	if region in [3,4]:_finish_gates(level)

func _finish_gates(node: Node) -> void:
	if node is CoopGate:
		if node.has_node("RegionalFinish"):return
		var art:=Node2D.new()
		art.set_script(load("res://regional_gate_finish.gd"))
		art.name="RegionalFinish"
		art.region=region
		node.add_child(art)
		return
	for child in node.get_children():_finish_gates(child)
