@tool
extends Node2D
const B=preload("res://journey_build.gd")
const Terminal=preload("res://tests/bmo_terminal.gd")
const ENV="res://Assets/02_Environments/06_friendship_portal/"
const LEFT_FLOOR=508.35286
const FLOOR=476.35286
@export_range(1,2) var primary_player_id:=1
var stage:=0
var checkpoint_stage:=0
var repaired: Array[bool]=[false,false,false]
var pair: Array[CoopPlayer]=[]
var actors: Node2D
var camera: SharedCamera
var hud: CanvasLayer
var bridge: JakeBridge
var permanent: PermanentBridge
var log: PushBlock
var structure_plate: PressurePlate
var reunion_a: Array[PressurePlate]=[]
var reunion_b: Array[PressurePlate]=[]
var confirmation: Array[PressurePlate]=[]
var portal: Node2D
var seals: Array[Sprite2D]=[]
var tunnel: Node2D
var switch_area: Area2D
var crank: Area2D
var lift: AnimatableBody2D
var music: Area2D
var receiver: CoopGate
var terminal: Area2D
var clue: Node2D
var crystal: FriendshipCrystal
var exit_area: CooperativeExit
var tunnel_visited:=false
var mechanism_unlocked:=false
var clue_revealed:=false
var confirmed:=false
var crystal_count:=0
var completion_count:=0
var recovery_count:=0
var _recovering:=false
var _transitioning:=false
var _starts: Array[Vector2]=[]
var repair_sound: AudioStreamPlayer
var portal_sound: AudioStreamPlayer
var live:=false
var message_left:=0.0

func _ready() -> void:
	if has_node("Players"): return
	if not Engine.is_editor_hint(): B.restore_restart_role(self,"primary_player_id")
	_build()
	if Engine.is_editor_hint(): return
	_activate_pair(0)
	camera=B.camera(self,pair[0],pair[1],1376)
	crystal.collected.connect(_crystal_collected)
	exit_area.level_completed.connect(_celebrate)
	repair_sound=B.sound(self,"puzzle_complete")
	portal_sound=B.sound(self,"portal_activate")
	var presentation:=Node2D.new()
	presentation.name="QualityPresentation"
	presentation.set_script(load("res://quality_presentation.gd"))
	add_child(presentation)
	live=true
	_note("Jake e Finn: restaurem o acesso ao portal.")
	DisplayServer.window_set_title("Portal da Amizade — um santuário, três reparos")

func _surface(name: String,x: float,y: float,width: float,height: float=12) -> StaticBody2D:
	var body=B.wall(self,name,Vector2(x+width*0.5,y+height*0.5),Vector2(width,height))
	var visual:=Node2D.new()
	visual.set_script(load("res://journey_surface.gd"))
	visual.set("size",Vector2(width,height))
	visual.set("top",load(ENV+"tiles/top.png"))
	visual.set("fill",load(ENV+"tiles/fill.png"))
	visual.position=Vector2(-width*0.5,-height*0.5)
	visual.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	body.add_child(visual)
	return body

func _build() -> void:
	B.background(self,ENV+"background.png")
	var terrain=B.tilemap(self,"Terrain",ENV+"tileset.tres",Vector2(0,-20.64714))
	terrain.tile_set=terrain.tile_set.duplicate(true)
	var atlas=terrain.tile_set.get_source(0)
	atlas.get_tile_data(Vector2i(1,0),0).set_collision_polygon_points(0,0,PackedVector2Array([Vector2(-16,1),Vector2(16,1),Vector2(16,16),Vector2(-16,16)]))
	B.fill(terrain,0,0,14,16,22)
	B.fill(terrain,0,19,43,15,22)
	B.wall(self,"LeftWall",Vector2(-8,300),Vector2(16,800))
	B.wall(self,"RightWall",Vector2(1384,300),Vector2(16,800))
	actors=Node2D.new()
	actors.name="Players"
	add_child(actors)
	portal=Node2D.new()
	portal.name="Portal"
	portal.set_script(load("res://portal_visual_clean.gd"))
	portal.set("texture",load(B.OBJECTS+"portal_damaged.png"))
	portal.position=Vector2(640,FLOOR-122)
	portal.scale=Vector2.ONE*2
	portal.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(portal)
	portal.z_index=-2
	for i in 3:
		seals.append(B.sprite(self,"Seal%d"%i,B.OBJECTS+"receiver_off.png",Vector2(544+i*96,182),0.65))
		B.label(self,["1 ESTRUTURA","2 MECANISMO","3 SINAL"][i],Vector2(500+i*96,212),12)
	bridge=B.packed(self,"JakeBridge","res://jake_bridge.tscn",Vector2(448,LEFT_FLOOR-26.35286))
	permanent=B.packed(self,"PermanentBridge","res://permanent_bridge.tscn",Vector2(528,LEFT_FLOOR-2.35286))
	permanent.get_node("CollisionShape2D").one_way_collision=true
	B.bridge_deck(permanent)
	log=B.log_block(self,"Counterweight",688,FLOOR)
	structure_plate=B.plate(self,"StructurePlate",Vector2(736,FLOOR),&"",true)
	reunion_a.append(B.plate(self,"FinnReunion",Vector2(640,FLOOR),&"push"))
	reunion_a.append(B.plate(self,"JakeReunion",Vector2(784,FLOOR),&"bridge"))
	B.label(self,"Encaixe do contrapeso",Vector2(672,536),13,"WeightHint")
	B.label(self,"Finn",Vector2(620,510),12,"FinnHint")
	B.label(self,"Jake",Vector2(770,510),12,"JakeHint")
	_surface("TunnelRoof",832,FLOOR-80,160,57.64714)
	tunnel=B.branch("res://tests/cake_test.tscn","Tunnel")
	tunnel.name="Tunnel"
	tunnel.get_node("LeftEntry").position=Vector2(804,FLOOR-20)
	tunnel.get_node("RightEntry").position=Vector2(1020,FLOOR-20)
	tunnel.get_node("Prompt").position=Vector2(816,536)
	add_child(tunnel)
	switch_area=B.area(self,"MechanismSwitch",Vector2(1036,FLOOR-26),Vector2(88,64))
	B.sprite(self,"SwitchIndicator",B.OBJECTS+"switch_off.png",Vector2(1040,350),0.6)
	lift=AnimatableBody2D.new()
	lift.name="ReturnLift"
	lift.position=Vector2(1280,FLOOR-50)
	lift.collision_layer=1
	lift.collision_mask=2
	lift.set_script(load("res://tests/fionna_platform.gd"))
	lift.set("extension",Vector2(-232,0))
	var lift_collider=B.collider(lift,Vector2(58,12),Vector2(0,6))
	lift_collider.one_way_collision=true
	B.sprite(lift,"Sprite2D",B.OBJECTS+"moving_platform.png",Vector2(0,2))
	add_child(lift)
	crank=B.branch("res://tests/cake_test.tscn","Crank")
	crank.name="Crank"
	crank.position=Vector2(896,FLOOR-112)
	crank.set("platform_path",NodePath("../ReturnLift"))
	crank.get_node("AnimatedSprite2D").position.y=3
	crank.get_node("Prompt").position=Vector2(-96,-56)
	crank.get_node("Status").position=Vector2(-80,-80)
	crank.monitoring=false
	crank.process_mode=Node.PROCESS_MODE_DISABLED
	add_child(crank)
	reunion_b.append(B.plate(self,"FionnaReunion",Vector2(864,FLOOR-80),&"crank"))
	reunion_b.append(B.plate(self,"CakeReunion",Vector2(960,FLOOR-80),&"crawl"))
	B.label(self,"Terraço",Vector2(832,260),14,"TerraceHint")
	_surface("FirstSignalStep",16,LEFT_FLOOR-48,64)
	_surface("SignalTakeoff",128,LEFT_FLOOR-96,64)
	_surface("ClueShelf",368,LEFT_FLOOR-96,96)
	for platform_name in ["FirstSignalStep","SignalTakeoff","ClueShelf"]:
		get_node(platform_name).hide()
		get_node(platform_name).collision_layer=0
	B.label(self,"Marceline: salto + flutuação",Vector2(160,266),13,"FloatHint")
	receiver=load("res://gate.tscn").instantiate()
	receiver.name="MusicReceiver"
	receiver.position=Vector2(416,300)
	receiver.collision_layer=0
	receiver.get_node("CollisionShape2D").disabled=true
	receiver.closed_texture=B.receiver_texture(B.OBJECTS+"receiver_off.png")
	receiver.open_texture=B.receiver_texture(B.OBJECTS+"receiver_on.png")
	receiver.get_node("Sprite2D").texture=receiver.closed_texture
	receiver.get_node("Sprite2D").position=Vector2.ZERO
	receiver.get_node("Sprite2D").offset.y=-8
	receiver.get_node("Sprite2D").scale=Vector2.ONE*0.5
	add_child(receiver)
	music=B.branch("res://tests/marceline_test.tscn","MusicPanel")
	music.set_script(load("res://journey_music.gd"))
	music.name="MusicPanel"
	music.position=Vector2(416,LEFT_FLOOR-128)
	music.get_node("Sprite2D").position.y=3
	music.set("gate_path",NodePath("../MusicReceiver"))
	music.monitoring=false
	music.process_mode=Node.PROCESS_MODE_DISABLED
	music.get_node("Prompt").position=Vector2(-72,-62)
	music.get_node("Status").position=Vector2(-100,54)
	add_child(music)
	terminal=B.branch("res://tests/bmo_test.tscn","SymbolTerminal")
	terminal.set_script(load("res://journey_terminal.gd"))
	terminal.name="SymbolTerminal"
	terminal.position=Vector2(568,LEFT_FLOOR-43.35286)
	terminal.get_node("Sprite2D").position.y=3
	terminal.get_node("Status").position=Vector2(-72,88)
	terminal.get_node("Prompt").position=Vector2(-56,-68)
	terminal.set("sequence",Array([2,0,1],TYPE_INT,"",null))
	terminal.set("gate_path",NodePath(".."))
	terminal.monitoring=false
	terminal.process_mode=Node.PROCESS_MODE_DISABLED
	add_child(terminal)
	clue=Node2D.new()
	clue.name="Clue"
	clue.position=Vector2(296,204)
	add_child(clue)
	for i in 3: B.sprite(clue,"Rune%d"%i,[B.OBJECTS+"rune_triangle.png",B.OBJECTS+"rune_circle.png",B.OBJECTS+"rune_square.png"][i],Vector2(i*48,0),0.6)
	B.label(clue,"triângulo • círculo • quadrado",Vector2(-36,26),12)
	clue.hide()
	confirmation.append(B.plate(self,"MusicConfirmation",Vector2(512,LEFT_FLOOR-11.35286),&"music"))
	confirmation.append(B.plate(self,"SignalConfirmation",Vector2(784,FLOOR),&"terminal"))
	crystal=load("res://crystal.tscn").instantiate()
	crystal.name="SixthCrystal"
	crystal.position=Vector2(640,FLOOR-34)
	crystal.collision_mask=0
	crystal.monitoring=false
	crystal.get_node("Sprite2D").texture=load(B.OBJECTS+"crystal_purple.png")
	crystal.hide()
	add_child(crystal)
	for plate in confirmation: plate.hide()
	exit_area=load("res://cooperative_exit.tscn").instantiate()
	exit_area.name="PortalExit"
	exit_area.position=Vector2(640,FLOOR-32)
	exit_area.crystal_path=NodePath("../SixthCrystal")
	var exit_shape:=RectangleShape2D.new()
	exit_shape.size=Vector2(160,128)
	exit_area.get_node("CollisionShape2D").shape=exit_shape
	exit_area.get_node("Sprite2D").hide()
	exit_area.get_node("Completion").modulate.a=0.0
	add_child(exit_area)
	hud=B.hud(self,"PORTAL DA AMIZADE • Um santuário, três reparos")
	var decor:=Node2D.new()
	decor.name="Scenery"
	decor.z_index=-1
	add_child(decor)
	for i in 10: B.sprite(decor,"CrystalPlant%d"%i,ENV+"tiles/decor_%02d.png"%(1+i%4),Vector2([32,240,288,344,800,1096,1152,1192,1320,1360][i],(LEFT_FLOOR if i<4 else FLOOR)-16))

func _activate_pair(index: int) -> void:
	var names: Array=[['Finn','Jake'],['Fionna','Cake'],['Marceline','BMO']]
	pair.clear()
	var origins: Array[Vector2]=[Vector2(128,LEFT_FLOOR-32.5),Vector2(192,LEFT_FLOOR-32.5)]
	if index==1: origins.assign([Vector2(624,FLOOR-32.5),Vector2(672,FLOOR-32.5)])
	elif index==2: origins.assign([Vector2(104,LEFT_FLOOR-32.5),Vector2(224,LEFT_FLOOR-32.5)])
	for i in 2:
		var actor=B.actor(actors,names[index][i],origins[i],primary_player_id if i==0 else 3-primary_player_id)
		pair.append(actor)
	_starts=[pair[0].position,pair[1].position]
	_set_presentation(index)
	if is_instance_valid(camera):
		camera.player_a=pair[0]
		camera.player_b=pair[1]
		camera.player_a_path=NodePath("../Players/"+pair[0].name)
		camera.player_b_path=NodePath("../Players/"+pair[1].name)
		camera.reset_smoothing()
	if index==1:
		crank.process_mode=Node.PROCESS_MODE_INHERIT
	if index==2:
		for platform_name in ["FirstSignalStep","SignalTakeoff","ClueShelf"]:
			get_node(platform_name).show()
			get_node(platform_name).collision_layer=1
		music.process_mode=Node.PROCESS_MODE_INHERIT
		music.monitoring=true
		terminal.process_mode=Node.PROCESS_MODE_INHERIT
		crank.process_mode=Node.PROCESS_MODE_DISABLED

func _set_presentation(index: int) -> void:
	for node in [receiver,music,terminal]: node.visible=index==2
	get_node("FloatHint").hide()
	for node in reunion_a: node.visible=index==0 and repaired[0]
	for name in ["WeightHint","FinnHint","JakeHint"]: get_node(name).visible=index==0
	for node in reunion_b: node.visible=index==1
	get_node("TerraceHint").visible=index==1
	tunnel.get_node("Prompt").visible=index==1
	for child in ["Prompt","Status"]: crank.get_node(child).visible=index==1
	if index!=0:
		bridge.get_node("AnchorPrompt").hide() if bridge.has_node("AnchorPrompt") else bridge.hide()

func _advance_pair(index: int) -> void:
	if _transitioning: return
	_transitioning=true
	exit_area._players_in_exit.clear()
	bridge._finish_retraction()
	if terminal.get("panel_open") or terminal.get("pending"): terminal.call("cancel")
	if crank.get("pending"): crank.call("cancel")
	for actor in pair:
		B.clean_actor(actor)
		actor.process_mode=Node.PROCESS_MODE_DISABLED
		actor.collision_layer=0
		actor.collision_mask=0
		actor.remove_from_group("players")
		actor.hide()
	_note("Reparo concluído!")
	if has_node("QualityPresentation"): await get_node("QualityPresentation").fade_out()
	await get_tree().physics_frame
	await get_tree().physics_frame
	stage=index
	checkpoint_stage=index
	_activate_pair(index)
	for actor in pair:
		# Settle the safe spawn with physics before freezing input during the handoff.
		actor.velocity=Vector2(0,60)
		actor.move_and_slide()
		actor.velocity=Vector2.ZERO
		actor.movement_locked=true
		actor.set_meta("pair_handoff_lock",true)
	if has_node("QualityPresentation"): await get_node("QualityPresentation").fade_in()
	while InputMap.get_actions().any(func(action):return (String(action).begins_with("p1_") or String(action).begins_with("p2_")) and Input.is_action_pressed(action)):
		_note("Soltem as teclas para começar com a nova dupla.")
		await get_tree().physics_frame
	for actor in pair:
		actor.movement_locked=false
		if actor.has_meta("pair_handoff_lock"): actor.remove_meta("pair_handoff_lock")
		actor.set("_jump_buffer_left",0.0)
		actor.set("_coyote_left",0.0)
	_transitioning=false
	_note("%s — P%d   •   %s — P%d"%[pair[0].name,pair[0].player_id,pair[1].name,pair[1].player_id])

func _repair(index: int) -> void:
	if repaired[index]: return
	repaired[index]=true
	if index==2:
		for plate in confirmation: plate.show()
	if is_instance_valid(repair_sound): repair_sound.play()
	seals[index].texture=B.receiver_texture(B.OBJECTS+"receiver_on.png")
	seals[index].modulate=Color.WHITE
	portal.set("texture",load(B.OBJECTS+("portal_active.png" if repaired.all(func(v):return v) else "portal_repaired.png")))
	if index==0:
		log.settled=true
		for node in reunion_a: node.show()
		for name in ["FinnHint","JakeHint"]: get_node(name).show()
		permanent.open_gate()
		log.set("_start_transform",log.global_transform)
	_note(["Estrutura reparada! Um em cada placa.","Mecanismo reparado!","Sinal restaurado! Confirmem nas placas."][index])

func open_gate() -> void:
	# Context target of the existing BMO terminal, not a new terminal system.
	if stage==2 and clue_revealed: _repair(2)

func _physics_process(_delta: float) -> void:
	if not live or Engine.is_editor_hint() or _transitioning or _recovering or completion_count>0: return
	B.poll_bridge_cancel(bridge)
	if pair.any(func(actor):return actor.position.y>710):
		recover_pair()
		return
	if stage==0:
		if structure_plate.is_active() and log.position.x>=720: _repair(0)
		if repaired[0] and reunion_a.all(func(p):return p.is_active()): _advance_pair(1)
	elif stage==1:
		var cake=pair[1]
		if cake.crawling and cake.position.x>850 and cake.position.x<970 and cake.position.y>FLOOR-50: tunnel_visited=true
		if crank.get("solved") and lift.get("extended") and reunion_b.all(func(p):return p.is_active()):
			_repair(1)
			_advance_pair(2)
	elif stage==2:
		if receiver.is_open and not clue_revealed:
			clue_revealed=true
			clue.show()
			terminal.set_deferred("monitoring",true)
			_note("Marceline revelou: triângulo, círculo, quadrado. BMO, conecte esse sinal no terminal.")
		if repaired[2] and not confirmed and confirmation.all(func(p):return p.is_active()):
			confirmed=true
			crystal.show()
			crystal.collision_mask=2
			crystal.set_deferred("monitoring",true)
			_note("CONFIRMAÇÃO EM DUPLA! O sexto cristal está pronto. Entrem juntos no portal.")

func _process(_delta: float) -> void:
	if not live or Engine.is_editor_hint() or pair.size()!=2: return
	message_left=maxf(0.0,message_left-_delta)
	if message_left<=0.0: hud.get_node("Message").text=""
	hud.get_node("Hints").text="P%d %s   •   P%d %s"%[pair[0].player_id,pair[0].name,pair[1].player_id,pair[1].name]
	var completed:=int(repaired[0])+int(repaired[1])+int(repaired[2])
	var objective="Jake: prepare a passagem para Finn."
	if bridge._bridge_active: objective="Finn: atravesse e leve o tronco ao encaixe."
	if stage==0 and repaired[0]: objective="Finn e Jake: um em cada placa do portal."
	if stage==1:
		objective="Cake: passe pelo túnel e libere a manivela."
		if mechanism_unlocked: objective="Fionna: use o tronco e opere a manivela."
		if crank.get("solved"): objective="Reúnam-se no terraço. O apoio de retorno está disponível."
	elif stage==2:
		objective="Marceline: suba à esquerda para alcançar o painel."
		if pair[0].is_on_floor() and pair[0].position.y<400: objective="Marceline: segure a habilidade no ar para flutuar."
		if clue_revealed: objective="BMO: conecte as formas mostradas na pista."
	if repaired[2]: objective="Marceline: placa da ponte. BMO: placa à direita."
	if confirmed: objective="Recuperem o cristal e entrem juntos no portal."
	if completion_count>0: objective="Os seis reunidos! Portal da Amizade restaurado."
	hud.get_node("Status").text="%d/3 reparos • "%completed+objective
	if _transitioning or _recovering or completion_count>0: return
	if stage==1:
		var cake=pair[1]
		tunnel.call("update_prompt",cake)
		if mechanism_unlocked: crank.call("update_prompt",pair[0])
		else: crank.get_node("Prompt").text="Cake: interruptor após o túnel"
		if Input.is_action_just_pressed(cake.get_interact_action()):
			if tunnel_visited and switch_area.overlaps_body(cake) and cake.is_on_floor() and not mechanism_unlocked:
				mechanism_unlocked=true
				crank.set_deferred("monitoring",true)
				get_node("SwitchIndicator").texture=load(B.OBJECTS+"switch_on.png")
				_note("MANIVELA LIBERADA! Fionna: use o tronco como degrau até o terraço.")
			elif cake.crawling: cake.request_stand()
			else: tunnel.call("interact",cake)
		if Input.is_action_just_pressed(pair[0].get_interact_action()) and not is_instance_valid(pair[0].get("interaction_owner")): crank.call("interact",pair[0])
	elif stage==2:
		if terminal.monitoring: terminal.call("update_prompt",pair[1])
		else: terminal.get_node("Prompt").text="Marceline: revele a pista musical."
		if terminal.get("solved"): terminal.get_node("Status").text="SINAL CONECTADO"
		elif not terminal.get("panel_open"): terminal.get_node("Status").text="BMO: conecte as três formas" if clue_revealed else "Aguardando a pista musical"
		music.get_node("Status").text="PISTA: triângulo, círculo, quadrado" if clue_revealed else "Marceline: toque o painel"
		var owner=pair[1].get("interaction_owner")
		if is_instance_valid(owner): owner.call("process_operator_input")
		elif clue_revealed and Input.is_action_just_pressed(pair[1].get_interact_action()): terminal.call("interact",pair[1])

func recover_pair() -> void:
	if _recovering or _transitioning or completion_count>0: return
	_recovering=true
	exit_area._players_in_exit.clear()
	bridge._finish_retraction()
	if terminal.get("panel_open") or terminal.get("pending"): terminal.call("cancel")
	if crank.get("pending"): crank.call("cancel")
	if not repaired[0] or (stage==1 and (log.position.x<700 or log.position.x>790)): log.reset_to_start()
	for i in 2:
		B.clean_actor(pair[i])
		pair[i].process_mode=Node.PROCESS_MODE_DISABLED
		pair[i].position=_starts[i]
		pair[i].velocity=Vector2.ZERO
	await get_tree().physics_frame
	await get_tree().physics_frame
	for actor in pair:
		B.clean_actor(actor)
		if actor.has_method("request_stand"): actor.call("request_stand")
		actor.process_mode=Node.PROCESS_MODE_INHERIT
		actor.velocity=Vector2.ZERO
	recovery_count+=1
	_recovering=false
	_note("Dupla do setor %d recuperada. Reparos e cristal conquistados continuam guardados."%(checkpoint_stage+1))

func _crystal_collected() -> void:
	crystal_count+=1
	_note("SEXTO CRISTAL RECUPERADO! Agora, os dois no portal.")

func _celebrate() -> void:
	if completion_count>0 or not repaired.all(func(v):return v) or not confirmed: return
	completion_count=1
	portal_sound.play()
	music.hide()
	terminal.hide()
	clue.hide()
	get_node("FloatHint").hide()
	for actor in pair:
		B.clean_actor(actor)
		actor.process_mode=Node.PROCESS_MODE_DISABLED
		actor.collision_layer=0
		actor.collision_mask=0
		actor.remove_from_group("players")
		actor.hide()
	portal.set("texture",load(B.OBJECTS+"portal_active.png"))
	_note("AMIZADE É CONSTRUIR JUNTOS. Portal restaurado, sexto cristal recuperado!")
	hud.get_node("Message").text=""
	message_left=0.0
	var layer:=CanvasLayer.new()
	layer.name="Celebration"
	layer.layer=12
	add_child(layer)
	var panel:=Panel.new()
	panel.position=Vector2(112,480)
	panel.size=Vector2(928,156)
	var style:=StyleBoxFlat.new()
	style.bg_color=Color("183642")
	style.border_color=Color("ffe69a")
	style.set_border_width_all(3)
	style.set_corner_radius_all(14)
	panel.add_theme_stylebox_override("panel",style)
	layer.add_child(panel)
	var names=["Finn","Jake","Fionna","Cake","Marceline","BMO"]
	for i in 6:
		var sprite:=AnimatedSprite2D.new()
		sprite.name=names[i]
		sprite.sprite_frames=load("res://Assets/01_Characters/%s/animations.tres"%names[i].to_lower())
		sprite.position=Vector2(216+i*144,536)
		sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		layer.add_child(sprite)
		sprite.play(&"celebrate" if sprite.sprite_frames.has_animation(&"celebrate") else &"idle")
		B.label(layer,names[i],Vector2(188+i*144,582),16)
	var button:=Button.new()
	button.text="Voltar à seleção de fases"
	button.position=Vector2(448,418)
	button.size=Vector2(256,42)
	button.focus_mode=Control.FOCUS_NONE
	B.style_button(button)
	button.pressed.connect(func(): get_tree().change_scene_to_file("res://phase_select.tscn"))
	layer.add_child(button)

func _note(text: String) -> void:
	hud.get_node("Message").text=text
	message_left=3.0

func _unhandled_key_input(event: InputEvent) -> void:
	if Engine.is_editor_hint() or not event is InputEventKey or not event.pressed or event.echo: return
	if event.keycode==KEY_F2: B.restart(self,"primary_player_id")
	elif event.keycode==KEY_ESCAPE:
		B.request_bridge_cancel(bridge)
		if crank.get("pending"): crank.call("cancel")
		if terminal.get("panel_open") or terminal.get("pending"): terminal.call("cancel")
		if pair.size()==2 and pair[1].has_method("request_stand"): pair[1].call("request_stand")
