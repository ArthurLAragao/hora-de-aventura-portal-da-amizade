extends Control
## HUD da aventura: retratos reais, papéis atuais e emblema dos cristais desta sessão.
## Não cria vidas fictícias nem interfere nos controles, na coleta ou no checkpoint.
const UI=preload("res://scripts/ui/menu_layout.gd")
const PIXEL=preload("res://Assets/08_Fonts/PixelifySans.ttf")
const COLORS=[Color("7cd8ef"),Color("8be3b4"),Color("c69af2"),Color("ffb875"),Color("f1a9ce"),Color("e6c762")]
const NAMES={"finn":"Finn","jake":"Jake","marceline":"Marceline","bmo":"BMO","fionna":"Fionna","cake":"Cake"}
var screens: Node
var design: Control
var roles: Array[Label]=[]
var portraits: Array[TextureRect]=[]
var emblem: Control
var count_label: Label
var acquired: Array=[]
var poll:=0.0
var cache: Dictionary={}

## Cria uma faixa compacta e responsiva, deixando o centro superior livre para o cenário.
func _ready() -> void:
	screens=get_parent().get_parent()
	name="AdventureHUD";mouse_filter=MOUSE_FILTER_IGNORE
	design=Control.new();design.size=Vector2(1152,648);design.mouse_filter=MOUSE_FILTER_IGNORE;add_child(design)
	for slot in 2:
		var x:=16+slot*150
		plaque(Rect2(x,14,142,58))
		var picture:=TextureRect.new();picture.position=Vector2(x+8,18);picture.size=Vector2(42,48)
		picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;picture.mouse_filter=MOUSE_FILTER_IGNORE;design.add_child(picture);portraits.append(picture)
		var role:=UI.label(design,"P%d"%(slot+1),Rect2(x+58,19,74,16),13);role.modulate=Color("e2c68e")
		roles.append(UI.label(design,"",Rect2(x+58,35,78,28),17))
	plaque(Rect2(804,14,332,66))
	count_label=UI.label(design,"Cristais recuperados · 0/6",Rect2(818,19,304,20),14)
	emblem=Control.new();emblem.position=Vector2(824,46);emblem.mouse_filter=MOUSE_FILTER_IGNORE;design.add_child(emblem);emblem.draw.connect(draw_emblem)
	var help:=UI.button(design,"Ajuda",Rect2(1000,90,64,28),"HelpAdventure");help.add_theme_font_size_override("font_size",13);help.focus_mode=Control.FOCUS_NONE;help.pressed.connect(screens.open_help)
	var menu:=UI.button(design,"Fases",Rect2(1070,90,66,28),"PhasesAdventure");menu.add_theme_font_size_override("font_size",13);menu.focus_mode=Control.FOCUS_NONE;menu.pressed.connect(screens.navigate.bind("res://phase_select.tscn",0))
	for button in [help,menu]:
		for state in ["normal","hover","pressed","focus"]:
			var style:=button.get_theme_stylebox(state).duplicate() as StyleBoxFlat
			style.set_corner_radius_all(0);style.border_color=Color("e4c88b");style.bg_color=Color("182d36f2");button.add_theme_stylebox_override(state,style)
	get_viewport().size_changed.connect(fit);fit();sync()

## Moldura de metal e madeira escura, em degraus e sem cantos suavizados.
func plaque(rect: Rect2) -> void:
	var p:=UI.panel(design,rect)
	var style:=p.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	style.bg_color=Color("182d36f2");style.border_color=Color("bba675");style.set_corner_radius_all(0);style.set_border_width_all(2)
	style.shadow_color=Color("081923a0");style.shadow_offset=Vector2(0,3);style.shadow_size=0;p.add_theme_stylebox_override("panel",style)
	for dx in [4.0,rect.size.x-6]:
		var rivet:=ColorRect.new();rivet.color=Color("e4c88b");rivet.position=rect.position+Vector2(dx,5);rivet.size=Vector2(2,2);rivet.mouse_filter=MOUSE_FILTER_IGNORE;design.add_child(rivet)

## Escala a HUD inteira; não muda resolução ou câmera do mundo.
func fit() -> void:
	if not is_inside_tree() or is_queued_for_deletion():return
	UI.fit(design,get_viewport().get_visible_rect().size,Vector2(1152,648))
	var story=screens.level.get_node_or_null("FriendshipStory")
	if story!=null and story.is_inside_tree() and not story.is_queued_for_deletion():
		story.set_meta("presentation_top_margin",maxf(112.0,design.position.y+136.0*design.scale.y))
		if is_instance_valid(story.card):story.layout_card(true)

## Observa o estado persistente da coleta, nunca a existência do sprite já removido.
func sync() -> void:
	var story=screens.level.get_node_or_null("FriendshipStory")
	if story==null or not story.ready_to_watch:return
	var state: Dictionary=story.snapshot()
	acquired=get_tree().get_meta("friendship_crystals",[]).duplicate()
	if state.get("crystal",false) and not screens.phase in acquired:
		acquired.append(screens.phase);get_tree().set_meta("friendship_crystals",acquired.duplicate())
	count_label.text="Cristais recuperados · %d/6"%acquired.size();emblem.queue_redraw()
	for slot in 2:
		var id:=""
		for actor in get_tree().get_nodes_in_group("players"):
			if actor.player_id==slot+1 and actor.is_visible_in_tree() and actor.process_mode!=Node.PROCESS_MODE_DISABLED:
				id=String(actor.character_id);break
		if id.is_empty():continue
		roles[slot].text=NAMES.get(id,id.capitalize())
		if not cache.has(id):cache[id]=load("res://Assets/01_Characters/%s/portrait.png"%id)
		portraits[slot].texture=cache[id]
	visible=not screens.help_open and not screens.leaving and not (screens.phase==6 and screens.completed())

## Seis encaixes numerados: forma facetada, brilho e preenchimento distinguem a conquista.
func draw_emblem() -> void:
	for i in 6:
		var at:=Vector2(i*50+10,10);var lit: bool=i+1 in acquired
		var points:=PackedVector2Array([at+Vector2(-8,-4),at+Vector2(0,-12),at+Vector2(8,-4),at+Vector2(6,5),at+Vector2(0,10),at+Vector2(-6,5)])
		emblem.draw_colored_polygon(points,Color("12202e"));emblem.draw_polyline(points+PackedVector2Array([points[0]]),Color("8c826a"),2)
		if lit:
			emblem.draw_colored_polygon(PackedVector2Array([at+Vector2(-5,-3),at+Vector2(0,-9),at+Vector2(5,-3),at+Vector2(0,7)]),COLORS[i])
			emblem.draw_line(at+Vector2(0,-7),at+Vector2(0,5),Color("fff1c6"),2)
		emblem.draw_string(PIXEL,at+Vector2(14,4),str(i+1),HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("e7d9b2") if lit else Color("8d9ca2"))

## Frequência baixa: não há consulta de estados ou carregamento de retratos por quadro.
func _process(delta: float) -> void:
	poll-=delta
	if poll<=0:poll=0.15;sync()
