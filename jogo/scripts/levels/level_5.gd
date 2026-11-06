extends Node2D
## Torre dos Espelhos: três circuitos discretos, sem dano e sem simulação óptica contínua.
const B=preload("res://scripts/core/journey_build.gd")
const ENV="res://Assets/02_Environments/05_mirror_tower/"
@export_range(1,2) var lead_player_id:=1
@export_range(1,16) var reflection_limit:=12
@export var initial_orientations: Array[int]=[1,0,0,1,0,1]
var marceline: CoopPlayer
var cake: CoopPlayer
var mirrors: Array[Dictionary]=[]
var receivers: Array[Dictionary]=[]
var emitters: Array[Dictionary]=[]
var blockers: Array[Rect2]=[]
var gates: Array[CoopGate]=[]
var solved: Array[bool]=[false,false,false]
var beams: Array=[]
var tunnel: Node2D
var tunnel2: Node2D
var hud: CanvasLayer
var crystal: FriendshipCrystal
var exit_area: CooperativeExit
var checkpoint_active:=false
var completion_count:=0
var recovery_count:=0
var recovering:=false
var checkpoint_sprite: Sprite2D

## Constrói somente esta fase e reutiliza personagens/mecanismos de execução.
func _ready() -> void:
	B.restore_restart_role(self,"lead_player_id")
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	B.background(self,ENV+"background.png")
	get_node("Background/Panorama").scale=Vector2.ONE*2
	get_node("Background/Panorama").position=Vector2(640,360)
	for x in range(0,2208,32):surface("Floor%d"%x,x,500,32,140)
	B.wall(self,"Left",Vector2(-12,350),Vector2(24,700))
	B.wall(self,"Right",Vector2(2220,350),Vector2(24,700))
	var players:=Node2D.new();players.name="Players";add_child(players)
	marceline=B.actor(players,"Marceline",Vector2(160,467.5),lead_player_id)
	cake=B.actor(players,"Cake",Vector2(224,467.5),3-lead_player_id)
	B.camera(self,marceline,cake,2208)
	hud=B.hud(self,"TORRE DOS ESPELHOS")
	hud.get_node("Hints").text="P%d Marceline · P%d Cake"%[lead_player_id,3-lead_player_id]
	var help:=B.label(hud,"P1: A/D · Espaço/W · E · Q\nP2: setas · Cima · Enter · Shift direito\nE/Enter: girar espelho · F2: reiniciar · Esc: postura\nMarceline: flutuar no ar. Cake: entrar rastejando.",Vector2(620,70),15,"Help")
	help.hide()
	var button:=Button.new();button.focus_mode=Control.FOCUS_NONE;button.text="Controles";button.position=Vector2(990,12);hud.add_child(button);button.pressed.connect(func():help.visible=not help.visible)
	for x in [560,1160,1760]:
		var gate:=B.gate(self,"Gate%d"%x,x,500,156);gates.append(gate)
		gate.position=Vector2(x,372);gate.collision_shape.shape.size=Vector2(64,256)
		blockers.append(Rect2(x-32,244,64,256));gate.get_node("Sprite2D").hide()
	# Primeiro circuito: incidência horizontal, saída para cima.
	surface("FirstMirrorStep",288,452,96,18)
	get_node("FirstMirrorStep/CollisionShape2D").one_way_collision=true
	add_mirror(Vector2(360,394),0,&"float",1)
	add_receiver(Vector2(360,274),0,"◇")
	emitters.append({"at":Vector2(260,394),"dir":Vector2.RIGHT,"sector":0})
	# Galeria: Cake desvia o raio sob o teto; Marceline completa o trajeto elevado.
	build_tunnel(700,"Tunnel");build_tunnel(1300,"Tunnel2")
	for x in [640,1240]:surface("Step%d"%x,x,452,64,18)
	for x in [852,1492]:surface("Balcony%d"%x,x,376,96,18)
	add_mirror(Vector2(780,488),1,&"crawl",0)
	add_mirror(Vector2(980,488),1,&"",0)
	add_mirror(Vector2(980,336),1,&"float",1)
	add_receiver(Vector2(1056,336),1,"○")
	emitters.append({"at":Vector2(780,480),"dir":Vector2.DOWN,"sector":1})
	# Duas rotas finais legíveis e de frente para o revestimento refletor.
	# A galeria anterior já combina o desvio de Cake com o espelho de Marceline.
	add_mirror(Vector2(1400,488),2,&"crawl",0)
	add_receiver(Vector2(1510,488),2,"△")
	emitters.append({"at":Vector2(1400,480),"dir":Vector2.DOWN,"sector":2})
	add_mirror(Vector2(1620,336),2,&"float",1)
	mirrors.back()["front_sign"]=-1
	add_receiver(Vector2(1700,336),2,"□")
	emitters.append({"at":Vector2(1620,488),"dir":Vector2.UP,"sector":2})
	B.area(self,"CheckpointArea",Vector2(1230,475),Vector2(80,50))
	checkpoint_sprite=B.sprite(self,"Checkpoint",B.OBJECTS+"checkpoint_off.png",Vector2(1220,468))
	crystal=load("res://crystal.tscn").instantiate();crystal.name="FriendshipCrystal";crystal.position=Vector2(1940,467);add_child(crystal)
	crystal.get_node("Sprite2D").texture=load(B.OBJECTS+"crystal_pink.png")
	crystal.monitoring=false;crystal.collected.connect(func():hud.get_node("Status").text="Quinto cristal recuperado. Sigam juntos!")
	exit_area=load("res://cooperative_exit.tscn").instantiate();exit_area.name="CooperativeExit";exit_area.crystal_path=NodePath("../FriendshipCrystal");exit_area.position=Vector2(2110,470);add_child(exit_area)
	exit_area.level_completed.connect(complete)
	for x in [40,200,640,1080,1240,1690,1860,2160]:
		B.sprite(self,"Decor%d"%x,ENV+"tiles/decor_01.png",Vector2(x,484))
	refresh_light()

## Desenha terreno com textura nativa e apoio físico de tamanho correspondente.
func surface(label: String,x: float,y: float,width: int,height: int) -> void:
	var body=B.wall(self,label,Vector2(x+width*0.5,y+height*0.5),Vector2(width,height))
	var visual:=Node2D.new();visual.set_script(load("res://scripts/scenery/journey_surface.gd"));visual.set("size",Vector2(width,height));visual.set("top",load(ENV+"tiles/top.png"));visual.set("fill",load(ENV+"tiles/fill.png"));visual.position=Vector2(-width*0.5,-height*0.5);body.add_child(visual)
	blockers.append(Rect2(x,y,width,height))

## Monta teto sólido e entradas reutilizando o túnel aprovado, sem teleporte.
func build_tunnel(x: int,label: String) -> void:
	surface(label+"Roof",x,420,160,58)
	var node=load("res://mechanisms/cake_tunnel.tscn").instantiate();node.name=label
	node.get_node("LeftEntry").position=Vector2(x-24,478);node.get_node("RightEntry").position=Vector2(x+184,478)
	node.get_node("Prompt").position=Vector2(x-16,382);add_child(node)
	for entry in ["LeftEntry","RightEntry"]:node.get_node(entry+"/Marker").hide()
	if label=="Tunnel":tunnel=node
	else:tunnel2=node

## Registra um espelho de duas orientações; capacidade vazia indica peça fixa.
func add_mirror(at: Vector2,sector: int,ability: StringName,orientation: int) -> void:
	if ability!=&"" and mirrors.size()<initial_orientations.size():orientation=posmod(initial_orientations[mirrors.size()],2)
	var sprite=B.sprite(self,"Mirror%d"%mirrors.size(),B.OBJECTS+"mirror_45.png",at,0.5)
	var prompt=B.label(self,"",at+Vector2(-48,-46),13)
	mirrors.append({"at":at,"sector":sector,"ability":ability,"orientation":orientation,"front_sign":(-1 if ability==&"float" and sector==1 else 1),"sprite":sprite,"prompt":prompt})

## Registra receptor identificado por forma, além da cor do feixe.
func add_receiver(at: Vector2,sector: int,symbol: String) -> void:
	var sprite=B.sprite(self,"Receiver%d"%receivers.size(),B.OBJECTS+"receiver_off.png",at,0.5)
	B.label(self,symbol,at+Vector2(-8,-38),18)
	sprite.offset=Vector2(0,9)
	receivers.append({"at":at,"sector":sector,"active":false,"sprite":sprite})

## Encontra o obstáculo mais próximo de um raio, incluindo portas e teto.
func stop_distance(at: Vector2,dir: Vector2) -> float:
	var distance:=600.0
	for rect in blockers:
		if rect.size.y==256 and gates.any(func(g):return g.is_open and absf(g.position.x-rect.get_center().x)<1):continue
		var points: Array=[rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)]
		for i in 4:
			var hit=Geometry2D.segment_intersects_segment(at,at+dir*distance,points[i],points[(i+1)%4])
			if hit!=null and at.distance_to(hit)>0.1:distance=minf(distance,at.distance_to(hit))
	return distance

## Recalcula raios por eventos; limita reflexões e interrompe ciclos determinísticos.
func refresh_light() -> void:
	beams.clear()
	for receiver in receivers:receiver.active=false
	for source in emitters:
		var at: Vector2=source.at;var dir: Vector2=source.dir;var seen: Dictionary={}
		for bounce in reflection_limit:
			var length:=stop_distance(at,dir);var target: Dictionary={};var mirror_hit:=false
			for candidate in mirrors+receivers:
				if candidate.sector!=source.sector:continue
				var delta: Vector2=candidate.at-at;var forward:=delta.dot(dir)
				if forward>1 and forward<=length and absf(delta.cross(dir))<1:
					length=forward;target=candidate;mirror_hit=candidate.has("orientation")
			beams.append([at,at+dir*length,source.sector])
			if target.is_empty():break
			if not mirror_hit:target.active=true;break
			var normal:=Vector2(-1,-1) if target.orientation==0 else Vector2(1,-1)
			if dir.dot(normal*target.front_sign)>=0:break
			var key:=str(target.at)+str(dir)
			if seen.has(key):break
			seen[key]=true
			dir=Vector2(-dir.y,-dir.x) if target.orientation==0 else Vector2(dir.y,dir.x)
			at=target.at+dir*2
	for i in 3:
		var group:=receivers.filter(func(r):return r.sector==i)
		if group.all(func(r):return r.active) and not solved[i]:solved[i]=true;gates[i].open_gate()
	for mirror in mirrors:
		var face:=AtlasTexture.new();face.atlas=load(B.OBJECTS+("mirror_45.png" if mirror.orientation==0 else "mirror_135.png"));face.region=Rect2(8,0,48,48)
		mirror.sprite.texture=face
	for receiver in receivers:receiver.sprite.texture=B.receiver_texture(B.OBJECTS+("receiver_on.png" if receiver.active else "receiver_off.png"))
	queue_redraw()

## Processa uma interação por personagem, priorizando entrada de túnel no alcance.
func _physics_process(_delta: float) -> void:
	if recovering or completion_count>0:return
	for mirror in mirrors:mirror.prompt.text=""
	for node in [tunnel,tunnel2]:node.prompt.text=("E" if cake.player_id==1 else "Enter")+": rastejar" if node.can_interact(cake) and not cake.crawling else ""
	for actor in [marceline,cake]:
		var candidates:=mirrors.filter(func(m):return m.ability!=&"" and actor.has_ability(m.ability) and not solved[m.sector] and actor.position.distance_to(m.at)<(54 if m.sector==0 else 76) and (m.ability!=&"crawl" or actor.crawling))
		candidates.sort_custom(func(a,b):return actor.position.distance_squared_to(a.at)<actor.position.distance_squared_to(b.at))
		if not candidates.is_empty():candidates[0].prompt.text=("E" if actor.player_id==1 else "Enter")+": girar"
		if Input.is_action_just_pressed(actor.get_interact_action()):
			if actor==cake and not cake.crawling and (tunnel.interact(cake) or tunnel2.interact(cake)):continue
			if not candidates.is_empty():candidates[0].orientation=1-candidates[0].orientation;refresh_light()
	if not checkpoint_active and solved[0] and solved[1] and $CheckpointArea.overlaps_body(marceline) and $CheckpointArea.overlaps_body(cake) and marceline.is_on_floor() and cake.is_on_floor() and marceline.position.y<520 and cake.position.y<520:
		checkpoint_active=true;checkpoint_sprite.texture=load(B.OBJECTS+"checkpoint_on.png")
	if solved[2] and is_instance_valid(crystal) and not crystal.is_collected:crystal.set_deferred("monitoring",true)
	if marceline.position.y>740 or cake.position.y>740:recover_pair()
	hud.get_node("Status").text="Reflitam a luz até o ◇." if not solved[0] else "Cake: caminho inferior. Marceline: espelho elevado." if not solved[1] else "Acendam △ e □ para abrir o caminho." if not solved[2] else ("Encontrem-se na saída." if exit_area._crystal_collected else "Recuperem o quinto cristal e sigam juntos.")

## Recupera a dupla sem conceder solução ou apagar estados conquistados.
func recover_pair() -> void:
	if recovering:return
	recovering=true
	exit_area._players_in_exit.clear()
	for actor in [marceline,cake]:
		B.clean_actor(actor)
		if actor.has_method("reset_after_recovery"):actor.reset_after_recovery()
		actor.velocity=Vector2.ZERO;actor.position=Vector2((1110 if checkpoint_active else 160)+(64 if actor==cake else 0),467.5)
	recovery_count+=1
	await get_tree().physics_frame
	recovering=false

## Finaliza uma vez e oferece ligação explícita com a fase final existente.
func complete() -> void:
	if completion_count>0:return
	completion_count=1
	for actor in [marceline,cake]:actor.movement_locked=true;actor.process_mode=Node.PROCESS_MODE_DISABLED
	exit_area.get_node("Completion").hide()
	for spec in [["Continuar: Portal da Amizade","res://level_6.tscn",420],["Seleção de fases","res://phase_select.tscn",720]]:
		var button:=Button.new();button.text=spec[0];button.position=Vector2(spec[2],560);B.style_button(button);hud.add_child(button);button.pressed.connect(func():
			if spec[1]=="res://level_6.tscn":get_tree().set_meta("journey_restart",{"scene":spec[1],"role":lead_player_id})
			get_tree().change_scene_to_file(spec[1]))
	hud.get_node("Status").text="Quinto cristal recuperado em dupla!"

## Reinicia por F2 preservando papéis; Esc solicita postura normal somente se livre.
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode==KEY_F2:B.restart(self,"lead_player_id")
		elif event.keycode==KEY_F1:$HUD/Help.visible=not $HUD/Help.visible
		elif event.keycode==KEY_ESCAPE:$HUD/Help.hide();cake.request_stand()

## Desenha feixes não nocivos atrás dos personagens e emissores fixados na arquitetura.
func _draw() -> void:
	for segment in beams:
		draw_line(segment[0],segment[1],Color("302b48"),6)
		draw_line(segment[0],segment[1],[Color("ffe4a1"),Color("94e9df"),Color("e9b7fa")][segment[2]],3)
		draw_line(segment[0],segment[1],Color("fff8da"),1)
	for x in [700,1300]:
		for edge in [x,x+156]:draw_rect(Rect2(edge,478,4,22),Color("635779"))
		draw_rect(Rect2(x,478,160,3),Color("39344e"))
	for receiver in receivers:
		if receiver.at.y<450:
			for y in range(0,int(receiver.at.y)-12,8):draw_rect(Rect2(receiver.at.x-1,y,2,6),Color("9b8aa4"))
	for mirror in mirrors:
		if mirror.ability==&"float" and mirror.sector>0:
			for y in range(0,int(mirror.at.y)-12,8):draw_rect(Rect2(mirror.at.x-1,y,2,6),Color("9b8aa4"))
	for source in emitters:draw_rect(Rect2(source.at-Vector2(5,5),Vector2(10,10)),Color("c4a869"))
	for mirror in mirrors:
		var normal: Vector2=(Vector2(-1,-1) if mirror.orientation==0 else Vector2(1,-1))*mirror.front_sign
		var center: Vector2=mirror.at
		var tangent:=Vector2(-normal.y,normal.x).normalized()*9
		draw_line(center-tangent,center+tangent,Color("2a293d"),5)
		draw_line(center-tangent+normal.normalized()*2,center+tangent+normal.normalized()*2,Color("c9f1ed"),2)
	for gate in gates:
		var at:=Vector2(gate.position.x-44,232)
		var art: Texture2D=preload("res://Assets/02_Environments/manual_review/tower_gate.png")
		if not gate.is_open:draw_texture(art,at)
		else:
			for x in [0,66]:draw_texture_rect_region(art,Rect2(at+Vector2(x,0),Vector2(22,268)),Rect2(x,0,22,268))
			draw_texture_rect_region(art,Rect2(at+Vector2(22,0),Vector2(44,26)),Rect2(22,0,44,26))
