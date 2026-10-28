@tool
extends Node2D
const B=preload("res://journey_build.gd")
const LEFT_FLOOR=402.35286
const FLOOR=362.35286
@export_range(1,2) var finn_player_id:=1
var finn: CoopPlayer
var jake: CoopPlayer
var bridge: JakeBridge
var permanent: PermanentBridge
var checkpoint: CoopCheckpoint
var fall: CoopFallZone
var tutorial_log: PushBlock
var log: PushBlock
var tutorial_plate: PressurePlate
var top_plate: PressurePlate
var log_plate: PressurePlate
var tutorial_gate: CoopGate
var relay_gate: CoopGate
var final_gate: CoopGate
var crystal: FriendshipCrystal
var exit_area: CooperativeExit
var hud: CanvasLayer
var tutorial_solved:=false
var relay_solved:=false
var crystal_count:=0
var completion_count:=0
var live:=false
var message_left:=0.0

func _ready() -> void:
	if has_node("Players"): return
	if not Engine.is_editor_hint(): B.restore_restart_role(self,"finn_player_id")
	_build()
	if Engine.is_editor_hint(): return
	crystal.collected.connect(_crystal_collected)
	exit_area.level_completed.connect(_complete)
	fall.recovery_started.connect(_prepare_recovery)
	fall.recovery_finished.connect(_recovered)
	var presentation:=Node2D.new()
	presentation.name="QualityPresentation"
	presentation.set_script(load("res://quality_presentation.gd"))
	add_child(presentation)
	live=true
	DisplayServer.window_set_title("Trilha da Casa na Árvore — construir o caminho juntos")

func _build() -> void:
	B.background(self,"res://Assets/02_Environments/01_tree_house/background.png")
	var terrain=B.tilemap(self,"TileMap","res://Assets/02_Environments/01_tree_house/tileset.tres")
	B.fill(terrain,1,0,20,20,35)
	B.fill(terrain,1,25,76,18,35)
	B.fill(terrain,1,48,61,14,15)
	B.wall(self,"LeftWall",Vector2(-8,290),Vector2(16,800))
	B.wall(self,"RightWall",Vector2(2440,290),Vector2(16,800))
	var actors:=Node2D.new()
	actors.name="Players"
	add_child(actors)
	finn=B.actor(actors,"Finn",Vector2(128,LEFT_FLOOR-32.5),finn_player_id)
	jake=B.actor(actors,"Jake",Vector2(192,LEFT_FLOOR-32.5),3-finn_player_id)
	tutorial_log=B.log_block(self,"TutorialLog",304,LEFT_FLOOR)
	tutorial_plate=B.plate(self,"TutorialPlate",Vector2(416,LEFT_FLOOR),&"",true)
	tutorial_gate=B.gate(self,"TutorialGate",544,LEFT_FLOOR,96)
	bridge=B.packed(self,"JakeBridge","res://jake_bridge.tscn",Vector2(640,376))
	bridge.process_mode=Node.PROCESS_MODE_DISABLED
	permanent=B.packed(self,"PermanentBridge","res://permanent_bridge.tscn",Vector2(720,400))
	permanent.get_node("CollisionShape2D").one_way_collision=true
	B.bridge_deck(permanent)
	var lever=load("res://lever.tscn").instantiate()
	lever.name="Lever"
	lever.position=Vector2(880,FLOOR-32)
	lever.gate_path=NodePath("../PermanentBridge")
	lever.get_node("Sprite2D").position.y=3
	add_child(lever)
	checkpoint=load("res://checkpoint.tscn").instantiate()
	checkpoint.name="Checkpoint"
	checkpoint.position=Vector2(1056,FLOOR)
	checkpoint.get_node("Sprite2D").scale=Vector2.ONE
	checkpoint.get_node("Sprite2D").position.y=-30
	checkpoint.get_node("FinnSpawn").position=Vector2(-32,-32.5)
	checkpoint.get_node("JakeSpawn").position=Vector2(32,-32.5)
	add_child(checkpoint)
	var trunk:=Node2D.new()
	trunk.name="TrunkPuzzle"
	add_child(trunk)
	log=B.log_block(trunk,"Log",1360,FLOOR)
	relay_gate=B.gate(self,"RelayGate",1712,FLOOR,64)
	top_plate=B.plate(self,"JakePlate",Vector2(1856,FLOOR-80),&"bridge")
	log_plate=B.plate(self,"LogPlate",Vector2(1856,FLOOR),&"",true)
	final_gate=B.gate(trunk,"Gate",2080,FLOOR,128)
	crystal=load("res://crystal.tscn").instantiate()
	crystal.name="FriendshipCrystal"
	crystal.position=Vector2(2224,FLOOR-34)
	crystal.monitoring=false
	crystal.collision_mask=0
	crystal.get_node("Sprite2D").texture=load(B.OBJECTS+"crystal_empty.png")
	add_child(crystal)
	exit_area=load("res://cooperative_exit.tscn").instantiate()
	exit_area.name="CooperativeExit"
	exit_area.position=Vector2(2336,FLOOR-32)
	exit_area.crystal_path=NodePath("../FriendshipCrystal")
	add_child(exit_area)
	fall=load("res://fall_zone.tscn").instantiate()
	fall.set_script(load("res://journey_fall_zone.gd"))
	fall.name="FallZone"
	fall.position=Vector2(1216,680)
	fall.finn_path=NodePath("../Players/Finn")
	fall.jake_path=NodePath("../Players/Jake")
	fall.checkpoint_path=NodePath("../Checkpoint")
	fall.starting_positions.assign([Vector2(128,LEFT_FLOOR-32.5),Vector2(192,LEFT_FLOOR-32.5)])
	add_child(fall)
	B.camera(self,finn,jake,2432)
	hud=B.hud(self,"TRILHA DA CASA NA ÁRVORE • Construam o caminho um para o outro")
	B.label(self,"1  Finn: tronco na placa\nJake: prepare a ponte",Vector2(256,230),16)
	B.label(self,"Um salta sobre o amigo;\no caminho reparado fica para os dois",Vector2(636,210),15)
	B.label(self,"ACAMPAMENTO\nO progresso fica guardado aqui",Vector2(972,224),15)
	B.label(self,"2  Um tronco, dois usos\nFinn aproxima; Jake usa como degrau",Vector2(1272,180),16)
	B.label(self,"JAKE: mantenha a placa\nFINN: leve o tronco até o encaixe",Vector2(1660,180),15)
	B.label(self,"REENCONTRO\nCristal e saída para os dois",Vector2(2180,192),15)
	B.sprite(self,"LogTarget",B.OBJECTS+"reset_arrow.png",Vector2(1488,FLOOR-6),0.5)
	var decor:=Node2D.new()
	decor.name="Scenery"
	decor.z_index=-1
	add_child(decor)
	var art:=Node2D.new()
	art.name="ArtDirection"
	art.set_script(load("res://stage_scenery.gd"))
	add_child(art)

func _physics_process(_delta: float) -> void:
	if not live or Engine.is_editor_hint(): return
	B.poll_bridge_cancel(bridge)
	tutorial_plate.completed=tutorial_solved
	top_plate.completed=relay_solved
	log_plate.completed=relay_solved
	if tutorial_plate.is_active() and tutorial_log.position.x>=400 and not tutorial_solved:
		tutorial_solved=true
		tutorial_log.settled=true
		tutorial_gate.open_gate()
		tutorial_log.set("_start_transform",tutorial_log.global_transform)
		bridge.process_mode=Node.PROCESS_MODE_INHERIT
		_note("Tronco encaixado. Caminho aberto.")
	if top_plate.is_active() or relay_solved:
		relay_gate.open_gate()
	elif relay_gate.is_open and B.safe_to_close(relay_gate): relay_gate._set_open_state(false)
	if not relay_solved and top_plate.is_active() and log_plate.is_active() and log.position.x>=1840:
		relay_solved=true
		log.set("_start_transform",log.global_transform)
		final_gate.open_gate()
		crystal.get_node("Sprite2D").texture=load(B.OBJECTS+"crystal_cyan.png")
		crystal.set_deferred("monitoring",true)
		crystal.collision_mask=2
		_note("O encaixe ficou firme! Jake já pode descer e reencontrar Finn.")

func _process(_delta: float) -> void:
	if not live or Engine.is_editor_hint(): return
	message_left=maxf(0.0,message_left-_delta)
	if message_left<=0.0: hud.get_node("Message").text=""
	hud.get_node("Hints").text="P%d Finn   •   P%d Jake"%[finn.player_id,jake.player_id]
	var goal="Abra a trilha."
	if tutorial_solved:
		goal="Construam a passagem."
		if bridge._bridge_active:
			goal="Abra o caminho do outro lado."
			if finn.position.x<640 and finn.is_on_floor(): goal="Finn: "+("Espaço/W" if finn.player_id==1 else "Cima")+" para subir no dorso."
	if permanent.visible: goal="Até o acampamento."
	if checkpoint.activated:
		goal="Unam os dois caminhos."
		if log.position.x>1460: goal="Alcancem os dois encaixes."
		if top_plate.is_active(): goal="Levem o tronco ao encaixe."
	if relay_solved: goal="Reúnam-se e recuperem o cristal."
	if crystal_count>0: goal="Cheguem juntos à bandeira de saída."
	if completion_count>0: goal="Caminho construído em dupla!"
	hud.get_node("Status").text=goal

func _note(text: String) -> void:
	hud.get_node("Message").text=text
	message_left=3.0

func _prepare_recovery() -> void:
	for actor in [finn,jake]: B.clean_actor(actor)

func _recovered(used_checkpoint: bool) -> void:
	_note("De volta ao acampamento." if used_checkpoint else "Vamos tentar juntos.")

func _crystal_collected() -> void:
	crystal_count+=1
	_note("Cristal da Amizade recuperado!")

func _complete() -> void:
	exit_area.get_node("Completion").modulate.a=0.0
	if completion_count>0: return
	completion_count=1
	bridge._finish_retraction()
	for actor in [finn,jake]:
		B.clean_actor(actor)
		actor.movement_locked=true
	_note("")
	var title=B.label(hud,"Caminho construído em dupla!",Vector2(0,132),28)
	title.size.x=1152
	title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	var button:=Button.new()
	button.text="Voltar à seleção de fases"
	button.position=Vector2(448,570)
	button.size=Vector2(256,44)
	button.focus_mode=Control.FOCUS_NONE
	B.style_button(button)
	button.pressed.connect(func():get_tree().change_scene_to_file("res://phase_select.tscn"))
	hud.add_child(button)

func _unhandled_key_input(event: InputEvent) -> void:
	if Engine.is_editor_hint() or not event is InputEventKey or not event.pressed or event.echo: return
	if event.keycode==KEY_F2: B.restart(self,"finn_player_id")
	elif event.keycode==KEY_ESCAPE: B.request_bridge_cancel(bridge)
