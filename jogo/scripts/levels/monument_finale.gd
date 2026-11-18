extends Node2D
## Epílogo jogável: os cristais conquistados voltam ao monumento, um por interação.
const B=preload("res://scripts/core/journey_build.gd")
const PROGRESS=preload("res://scripts/core/campaign_progress.gd")
const PALETTE=preload("res://scripts/ui/crystal_emblem.gd").COLORS
const REGIONS=["01_tree_house","02_ice_kingdom","03_musical_cave","04_candy_workshop","05_mirror_tower","06_friendship_portal"]
const NAMES=["Trilha","Gelo","Música","Oficina","Espelhos","Amizade"]
@export_range(1,2) var primary_player_id:=1
var actors: Array[CoopPlayer]=[]
var placed: Array[int]=[]
var pedestals: Array[Vector2]=[]
var available: Array=[]
var saved_window: Array=[]
var clock:=0.0
var finished:=false
var celebration_started:=false
var finish_time:=0.0
var title: Label
var prompt: Label
var dialogue: Label
var portal: Node2D
var glow: ColorRect
var base_textures: Array[Texture2D]=[]
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
		base_textures.append(load("res://Assets/02_Environments/"+REGIONS[i]+"/tiles/fill.png"))
		var texture: Texture2D=load("res://Assets/02_Environments/"+REGIONS[i]+"/tiles/top.png")
		var base:=Sprite2D.new();base.texture=texture;base.region_enabled=true;base.region_rect=Rect2(0,0,32,32);base.position=at+Vector2(0,-16);base.z_index=-1;add_child(base)
		var label:=B.label(self,NAMES[i],at+Vector2(-45,12),13);label.size.x=90;label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	canvas=CanvasLayer.new();canvas.layer=25;add_child(canvas);design=Control.new();design.size=Vector2(1152,648);canvas.add_child(design)
	title=preload("res://scripts/ui/menu_layout.gd").label(design,"DEVOLVAM OS CRISTAIS AO MONUMENTO",Rect2(90,32,972,40),26);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	dialogue=preload("res://scripts/ui/menu_layout.gd").label(design,"Marceline: Cada cristal guarda um caminho que construímos juntos.",Rect2(112,86,928,52),19,true);dialogue.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	prompt=preload("res://scripts/ui/menu_layout.gd").label(design,"",Rect2(80,586,992,36),21);prompt.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	glow=ColorRect.new();glow.size=Vector2(1152,648);glow.color=Color(0.76,0.96,0.86,0);glow.mouse_filter=Control.MOUSE_FILTER_IGNORE;design.add_child(glow)
	get_viewport().size_changed.connect(fit);fit()
	var atmosphere:=Node2D.new();atmosphere.set_script(load("res://scripts/scenery/world_atmosphere.gd"));atmosphere.set("phase",6);add_child(atmosphere)

func fit() -> void:preload("res://scripts/ui/menu_layout.gd").fit(design,get_viewport().get_visible_rect().size,Vector2(1152,648))
func nearest(actor: CoopPlayer) -> int:
	var chosen:=-1;var distance:=76.0
	for i in 6:
		if i+1 in placed or not i+1 in available:continue
		var d:=absf(actor.position.x-pedestals[i].x)
		if d<distance and actor.is_on_floor():distance=d;chosen=i
	return chosen
func _process(delta: float) -> void:
	clock+=delta;prompt.text=""
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
	queue_redraw()
func place(index: int) -> bool:
	if finished or index+1 in placed or not index+1 in available:return false
	placed.append(index+1)
	dialogue.text=["O primeiro caminho nasceu quando ajudamos um ao outro.","Cake e Fionna abriram passagem pelo gelo.","Ouvir e compartilhar pistas fez a música voltar.","Cada amigo cuidou de uma parte da mesma máquina.","Juntas, enxergamos um caminho de luz.","Todos os amigos têm um lugar neste mundo."][index]
	if placed.size()==6:
		finished=true;PROGRESS.restore_world();title.text="A LUZ DA AMIZADE VOLTOU!"
	return true
func _draw() -> void:
	# A fundação contínua é jogável; os pedestais são objetos de fundo, não falsos degraus.
	for x in range(0,1152,32):
		for y in range(520,648,32):draw_texture(preload("res://Assets/02_Environments/06_friendship_portal/tiles/fill.png"),Vector2(x,y),Color("698a8b"))
		draw_texture(preload("res://Assets/02_Environments/06_friendship_portal/tiles/top.png"),Vector2(x,503))
	for i in pedestals.size():
		var at:=pedestals[i];var lit: bool=i+1 in placed;var color: Color=PALETTE[i]
		draw_rect(Rect2(at.x-28,at.y-16,56,16),Color("294a53"));draw_rect(Rect2(at.x-28,at.y-18,56,3),Color("b8b687"))
		draw_line(at-Vector2(0,22),Vector2(at.x,510),color if lit else Color("516e71"),3)
		# Símbolos gravados diferentes: ramos, gelo, notas, engrenagem, espelho e portal.
		for step in 3:
			var y:=at.y-32-step*6
			draw_line(Vector2(at.x-7+step,y),Vector2(at.x+7-step,y+(i%3)*2),color.darkened(0.22),2)
		monument_body(i,at,lit)
		var center:=at+Vector2(0,-112)
		var width:=12.0*maxf(0.35,absf(cos(clock*0.7+i))) if lit else 12.0
		var p:=PackedVector2Array([center+Vector2(0,-20),center+Vector2(width,-6),center+Vector2(width*0.8,10),center+Vector2(0,20),center+Vector2(-width*0.8,10),center+Vector2(-width,-6)])
		if lit:draw_circle(center,26,Color(color,0.09+0.035*sin(clock*2+i)))
		draw_colored_polygon(p,color if lit else Color("17313e"));draw_polyline(p+PackedVector2Array([p[0]]),Color("efdfaa") if lit else Color("6b8989"),2)
		if lit:draw_line(center+Vector2(-2,-12),center+Vector2(-2,7),Color("fff5d2"),2)

## Seis materiais e silhuetas próprios: árvore, gelo, órgão, engrenagem, espelho e arco.
func monument_body(index: int,at: Vector2,lit: bool) -> void:
	var ink:=Color("21343f");var edge: Color=PALETTE[index].darkened(0.25)
	for row in 2:
		for column in 2:draw_texture_rect_region(base_textures[index],Rect2(at+Vector2(-32+column*32,-80+row*32),Vector2(32,32)),Rect2(0,0,32,32),Color("8aa6a5"))
	draw_rect(Rect2(at.x-38,at.y-20,76,9),ink);draw_rect(Rect2(at.x-36,at.y-20,72,3),edge)
	match index:
		0:
			for x in [-28,-16,0,16,28]:draw_line(at+Vector2(x,-18),at+Vector2(x+3,-72),Color("664b37"),3)
			for side in [-1,1]:
				draw_rect(Rect2(at+Vector2(side*34-8,-75),Vector2(16,8)),Color("477859"));draw_rect(Rect2(at+Vector2(side*28-6,-84),Vector2(12,9)),Color("7aab68"))
		1:
			for x in [-30,-15,15,30]:
				draw_colored_polygon(PackedVector2Array([at+Vector2(x-5,-23),at+Vector2(x-5,-73),at+Vector2(x,-89),at+Vector2(x+5,-73),at+Vector2(x+5,-23)]),Color("86bccd"));draw_line(at+Vector2(x-2,-70),at+Vector2(x-2,-29),Color("dbf0df"),2)
		2:
			for i in 5:
				var x: int=-24+i*12;var y: int=-76-absi(2-i)*4
				draw_rect(Rect2(at+Vector2(x-4,y),Vector2(8,-20-y)),Color("526984"));draw_rect(Rect2(at+Vector2(x-3,y),Vector2(2,-26-y)),Color("9ab0c5"));draw_rect(Rect2(at+Vector2(x-2,y+3),Vector2(4,5)),ink)
		3:
			for side in [-1,1]:
				var center:=at+Vector2(side*27,-48)
				draw_circle(center,13,Color("715648"));draw_arc(center,10,0,TAU,16,Color("d4a46e"),3)
				for tooth in 4:
					var offset:=Vector2(cos(tooth*PI/2),sin(tooth*PI/2))*13;draw_rect(Rect2(center+offset-Vector2(3,3),Vector2(6,6)),Color("d4a46e"))
				draw_circle(center,4,ink)
		4:
			var center:=at+Vector2(0,-48);var p:=PackedVector2Array([center+Vector2(0,-25),center+Vector2(19,0),center+Vector2(0,25),center+Vector2(-19,0)])
			draw_colored_polygon(p,Color("647c8d"));draw_polyline(p+PackedVector2Array([p[0]]),Color("d6bf8a"),3);draw_line(center+Vector2(-5,-10),center+Vector2(5,6),Color("daebdf"),2)
		5:
			draw_rect(Rect2(at+Vector2(-18,-65),Vector2(36,46)),ink)
			for side in [-1,1]:draw_rect(Rect2(at+Vector2(side*19-4,-65),Vector2(8,46)),Color("93aaa0"))
			draw_arc(at+Vector2(0,-65),19,PI,TAU,16,Color("c1ae78"),7)
			if lit:draw_arc(at+Vector2(0,-47),10,clock,clock+PI*1.6,24,Color("b4ebcc"),2)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode==KEY_ESCAPE:get_tree().change_scene_to_file("res://phase_select.tscn")
		elif event.keycode==KEY_F2:get_tree().reload_current_scene()


## O enquadramento do epílogo é local; o menu recebe a configuração que já utilizava.
func _exit_tree() -> void:
	if saved_window.size()==3 and get_window()!=null:
		var window:=get_window();window.content_scale_size=saved_window[0];window.content_scale_mode=saved_window[1];window.content_scale_aspect=saved_window[2]
