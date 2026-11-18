extends Node2D
## Epílogo jogável: os cristais conquistados voltam ao monumento, um por interação.
const ART=preload("res://scripts/ui/sprite_art.gd")
const B=preload("res://scripts/core/journey_build.gd")
const PROGRESS=preload("res://scripts/core/campaign_progress.gd")
const PALETTE=preload("res://scripts/ui/crystal_emblem.gd").COLORS
const NAMES=["Trilha","Gelo","Música","Oficina","Espelhos","Amizade"]
@export_range(1,2) var primary_player_id:=1
var actors: Array[CoopPlayer]=[]
var placed: Array[int]=[]
var pedestals: Array[Vector2]=[]
var available: Array=[]
var saved_window: Array=[]
var finished:=false
var celebration_started:=false
var finish_time:=0.0
var title: Label
var prompt: Label
var dialogue: Label
var portal: Node2D
var glow: ColorRect
var monument_sprites: Array[Sprite2D]=[]
var crystal_sprites: Array[AnimatedSprite2D]=[]
var restoration_effects: Array[AnimatedSprite2D]=[]
var canvas: CanvasLayer
var design: Control

func _ready() -> void:
	var window:=get_window();saved_window=[window.content_scale_size,window.content_scale_mode,window.content_scale_aspect]
	window.content_scale_size=Vector2i(1152,648);window.content_scale_mode=Window.CONTENT_SCALE_MODE_CANVAS_ITEMS;window.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_KEEP
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	available=PROGRESS.read().crystals
	B.background(self,"res://Assets/02_Environments/06_friendship_portal/background.png")
	var panorama: Sprite2D=get_node("Background/Panorama");panorama.position=Vector2(576,324)
	panorama.scale=Vector2.ONE*maxf(1152.0/panorama.texture.get_width(),648.0/panorama.texture.get_height())
	B.wall(self,"CeremonyFloor",Vector2(576,568),Vector2(1152,96));B.wall(self,"Left",Vector2(-12,320),Vector2(24,700));B.wall(self,"Right",Vector2(1164,320),Vector2(24,700))
	var role: int=int(get_tree().get_meta("finale_role",primary_player_id))
	actors.append(B.actor(self,"Marceline",Vector2(80,487.5),role));actors.append(B.actor(self,"BMO",Vector2(144,488),3-role))
	B.camera(self,actors[0],actors[1],1152)
	portal=Node2D.new();portal.name="RestoredPortal";portal.set_script(load("res://scripts/scenery/portal_sanctuary.gd"));portal.position=Vector2(576,520);portal.scale=Vector2.ONE*2.6;portal.z_index=-2;add_child(portal)
	for i in 6:
		var at:=Vector2(144+i*172,520);pedestals.append(at)
		var body:=Sprite2D.new();body.name="Monument%d"%(i+1);body.texture=load(ART.ROOT+ART.MONUMENTS[i]+".png")
		body.position=at+Vector2(0,-48);body.z_index=-1;add_child(body);monument_sprites.append(body)
		var gem:=ART.gem(self,at+Vector2(0,ART.GEM_Y[i]-3),PALETTE[i],0.9);gem.name="RestoredCrystal%d"%(i+1);gem.z_index=-1;gem.hide();crystal_sprites.append(gem)
		var effect:=ART.burst(self,gem.position,PALETTE[i],1.5);effect.z_index=1;effect.hide();restoration_effects.append(effect)
		var label:=B.label(self,NAMES[i],at+Vector2(-45,12),13);label.size.x=90;label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	canvas=CanvasLayer.new();canvas.layer=25;add_child(canvas);design=Control.new();design.size=Vector2(1152,648);canvas.add_child(design)
	title=preload("res://scripts/ui/menu_layout.gd").label(design,"DEVOLVAM OS CRISTAIS AO MONUMENTO",Rect2(90,32,972,40),26);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	dialogue=preload("res://scripts/ui/menu_layout.gd").label(design,"Marceline: Cada cristal guarda um caminho que construímos juntos.",Rect2(112,86,928,52),19,true);dialogue.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	prompt=preload("res://scripts/ui/menu_layout.gd").label(design,"",Rect2(80,586,992,36),21);prompt.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	glow=ColorRect.new();glow.size=Vector2(1152,648);glow.color=Color(0.76,0.96,0.86,0);glow.mouse_filter=Control.MOUSE_FILTER_IGNORE;design.add_child(glow)
	get_viewport().size_changed.connect(fit);fit()
	var atmosphere:=Node2D.new();atmosphere.name="WorldAtmosphere";atmosphere.set_script(load("res://scripts/scenery/world_atmosphere.gd"));atmosphere.set("phase",6);add_child(atmosphere)

func fit() -> void:preload("res://scripts/ui/menu_layout.gd").fit(design,get_viewport().get_visible_rect().size,Vector2(1152,648))
func nearest(actor: CoopPlayer) -> int:
	var chosen:=-1;var distance:=76.0
	for i in 6:
		if i+1 in placed or not i+1 in available:continue
		var d:=absf(actor.position.x-pedestals[i].x)
		if d<distance and actor.is_on_floor():distance=d;chosen=i
	return chosen
func _process(delta: float) -> void:
	prompt.text=""
	portal.set("repairs",[placed.size()>=2,placed.size()>=4,placed.size()==6])
	if finished:
		finish_time+=delta;glow.color.a=0.22*sin(clampf(finish_time/3.0,0,1)*PI)
		portal.modulate=Color.WHITE
		if finish_time>0.5:dialogue.text="BMO: Seis amigos, seis cristais. A amizade trouxe a luz de volta!"
		if finish_time>4 and not celebration_started:
			celebration_started=true
			for actor in actors:B.clean_actor(actor);actor.hide();actor.process_mode=Node.PROCESS_MODE_DISABLED;actor.remove_from_group("players");actor.collision_layer=0
			canvas.hide();var ending:=CanvasLayer.new();ending.name="Celebration";ending.set_script(load("res://scripts/ui/friendship_ending.gd"));add_child(ending)
	else:
		for actor in actors:
			var index:=nearest(actor)
			if index<0:continue
			prompt.text=("E" if actor.player_id==1 else "Enter")+" · colocar o cristal de "+NAMES[index]
			if Input.is_action_just_pressed(actor.get_interact_action()):place(index)
		if available.size()<6:prompt.text="Faltam cristais da campanha. Voltem às fases para recuperá-los."
func place(index: int) -> bool:
	if finished or index+1 in placed or not index+1 in available:return false
	placed.append(index+1)
	crystal_sprites[index].show();restoration_effects[index].show();restoration_effects[index].play(&"activate")
	dialogue.text=["O primeiro caminho nasceu quando ajudamos um ao outro.","Cake e Fionna abriram passagem pelo gelo.","Ouvir e compartilhar pistas fez a música voltar.","Cada amigo cuidou de uma parte da mesma máquina.","Juntas, enxergamos um caminho de luz.","Todos os amigos têm um lugar neste mundo."][index]
	if placed.size()==6:
		finished=true;PROGRESS.restore_world();title.text="A LUZ DA AMIZADE VOLTOU!"
	return true
func _draw() -> void:
	# A fundação contínua é jogável; os pedestais são objetos de fundo, não falsos degraus.
	for x in range(0,1152,32):
		for y in range(520,648,32):draw_texture(preload("res://Assets/02_Environments/06_friendship_portal/tiles/fill.png"),Vector2(x,y),Color("698a8b"))
		draw_texture(preload("res://Assets/02_Environments/06_friendship_portal/tiles/top.png"),Vector2(x,503))
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode==KEY_ESCAPE:get_tree().change_scene_to_file("res://phase_select.tscn")
		elif event.keycode==KEY_F2:get_tree().reload_current_scene()


## O enquadramento do epílogo é local; o menu recebe a configuração que já utilizava.
func _exit_tree() -> void:
	if saved_window.size()==3 and get_window()!=null:
		var window:=get_window();window.content_scale_size=saved_window[0];window.content_scale_mode=saved_window[1];window.content_scale_aspect=saved_window[2]
