extends Control
## HUD da aventura: retratos reais, papéis atuais e emblema dos cristais desta sessão.
## Não cria vidas fictícias nem interfere nos controles, na coleta ou no checkpoint.
const ART=preload("res://scripts/ui/sprite_art.gd")
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
		var picture:=TextureRect.new();picture.position=Vector2(x+12,21);picture.size=Vector2(40,44)
		picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;picture.mouse_filter=MOUSE_FILTER_IGNORE;design.add_child(picture);portraits.append(picture)
		var role:=UI.label(design,"P%d"%(slot+1),Rect2(x+60,21,74,16),13);role.modulate=Color("e2c68e");role.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		var character:=UI.label(design,"",Rect2(x+58,38,78,24),17);character.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;roles.append(character)
	var relicary:=TextureRect.new();relicary.name="CrystalRelicary";relicary.texture=load(ART.ROOT+"hud_crystals.png")
	relicary.position=Vector2(846,14);relicary.size=Vector2(288,92);relicary.mouse_filter=MOUSE_FILTER_IGNORE;relicary.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;design.add_child(relicary)
	count_label=UI.label(design,"Cristais da Amizade · 0/6",Rect2(864,26,256,20),14)
	emblem=preload("res://scripts/ui/crystal_emblem.gd").new();emblem.position=Vector2(860,49);emblem.mouse_filter=MOUSE_FILTER_IGNORE;design.add_child(emblem)
	var help:=UI.button(design,"Ajuda",Rect2(1000,106,64,28),"HelpAdventure");help.add_theme_font_size_override("font_size",13);help.focus_mode=Control.FOCUS_NONE;help.pressed.connect(screens.open_help)
	var menu:=UI.button(design,"Fases",Rect2(1070,106,66,28),"PhasesAdventure");menu.add_theme_font_size_override("font_size",13);menu.focus_mode=Control.FOCUS_NONE;menu.pressed.connect(screens.navigate.bind("res://phase_select.tscn",0))
	for button in [help,menu]:ART.button(button)
	get_viewport().size_changed.connect(fit);fit();sync()

## Cartões com moldura PNG; os recortes preservam as bordas ao redimensionar.
func plaque(rect: Rect2) -> void:
	var p:=Panel.new();p.position=rect.position;p.size=rect.size;p.mouse_filter=MOUSE_FILTER_IGNORE
	p.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;p.add_theme_stylebox_override("panel",ART.skin());design.add_child(p)

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
	acquired=preload("res://scripts/core/campaign_progress.gd").read().crystals.duplicate()
	if state.get("crystal",false) and not screens.phase in acquired:
		acquired.append(screens.phase);get_tree().set_meta("friendship_crystals",acquired.duplicate());preload("res://scripts/core/campaign_progress.gd").collect(screens.phase)
	count_label.text="Cristais da Amizade · %d/6"%acquired.size();emblem.set_crystals(acquired)
	for slot in 2:
		var id:=""
		for actor in get_tree().get_nodes_in_group("players"):
			if actor.player_id==slot+1 and actor.is_visible_in_tree() and actor.process_mode!=Node.PROCESS_MODE_DISABLED:
				id=String(actor.character_id);break
		if id.is_empty():continue
		roles[slot].text=NAMES.get(id,id.capitalize())
		if not cache.has(id):
			var source: Texture2D=load("res://Assets/01_Characters/%s/portrait.png"%id)
			var crop:=AtlasTexture.new();crop.atlas=source;crop.region=source.get_image().get_used_rect();cache[id]=crop
		portraits[slot].texture=cache[id]
	visible=not story.modal_active and not screens.help_open and not screens.leaving and not (screens.phase==6 and screens.completed())

## Frequência baixa: não há consulta de estados ou carregamento de retratos por quadro.
func _process(delta: float) -> void:
	poll-=delta
	if poll<=0:poll=0.15;sync()
