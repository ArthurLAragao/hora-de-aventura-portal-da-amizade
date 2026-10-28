@tool
extends Node2D
## Reino Gelado: cooperative route with local checkpoint and joint completion.
@export_range(1,2) var cake_player_id := 2
@export_enum("Normal","Bloco","Túnel","Manivela","Ponte","Final") var test_start := 0
var crystal_collected:=false
var completed:=false
var completion_count:=0
var checkpoint_active:=false
var final_crystal: FriendshipCrystal
var final_exit: CooperativeExit
var checkpoint_flag: Sprite2D
var recovery_count := 0
var tunnel_visited := false
var first_unlocked := false
var _starts: Array[Vector2]=[]
@onready var cake=$Cake
@onready var fionna=$Fionna
@onready var anchor=$Anchor
@onready var tunnel=$Tunnel
@onready var crank=$Crank
@onready var first_crank=$FirstCrank

func _ready() -> void:
	_build_terrain()
	# Decoration is now composed by RegionalScenery, with no duplicate instances.
	if Engine.is_editor_hint(): return
	cake.player_id=cake_player_id
	cake.set_meta("player_id",cake.player_id)
	fionna.player_id=3-cake_player_id
	fionna.set_meta("player_id",fionna.player_id)
	first_crank.monitoring=false
	var origins: Array[Vector2]=[Vector2(128,487),Vector2(224,487),Vector2(420,487),Vector2(704,487),Vector2(1488,487),Vector2(2144,487)]
	var origin: Vector2=origins[test_start]
	cake.position=origin
	fionna.position=origin+Vector2(-64 if test_start>=2 else 64,0)
	if test_start==2: fionna.position=Vector2(256,487)
	if test_start==3: _unlock_first()
	_starts=[cake.position,fionna.position]
	_setup_finish()
	var ck:="A/D, Espaço/W, E, Q" if cake_player_id==1 else "Setas, Cima, Enter, Shift direito"
	var fk:="A/D, Espaço/W, E; R restaura bloco" if fionna.player_id==1 else "Setas, Cima, Enter; Backspace restaura bloco"
	$Instructions/Text.text="REINO GELADO • Cake P%d: %s • Fionna P%d: %s\nBloco como degrau; Cake rasteja e aciona o interruptor. Depois, manivelas e ponte. F2 reinicia; Esc cancela.\nCristal e saída: áreas reservadas; coleta/conclusão ainda pendentes.%s" % [cake_player_id,ck,fionna.player_id,fk,"\nINÍCIO DE TESTE: não representa progressão normal." if test_start>0 else ""]
	DisplayServer.window_set_title("Fase 2 — Passagem do Reino Gelado — cenário e mecanismos")

func _build_terrain() -> void:
	var terrain: TileMap=$Terrain
	terrain.clear()
	# 32×32 original ice grid. Flat support at world Y519.
	for column in 72:
		if column in [27,28,47,48]: continue
		for row in range(16,21): terrain.set_cell(0,Vector2i(column,row),0,Vector2i(1,0 if row==16 else 1))
	$Roof.clear()
	for column in range(14,19):
		for row in [13,14]: $Roof.set_cell(0,Vector2i(column,row),0,Vector2i(1,0 if row==13 else 1))
	# Clear side platforms mark the approach; they do not obstruct the main floor.
	for column in range(34,37): terrain.set_cell(0,Vector2i(column,13),0,Vector2i(3,0))

func _build_decoration() -> void:
	if has_node("IceScenery"): return
	var group:=Node2D.new()
	group.name="IceScenery"
	group.z_index=-1
	add_child(group)
	for index in 15:
		var x: float=[48,96,216,672,720,1008,1040,1200,1272,1320,1744,1808,1872,2032,2256][index]
		var deco:=Sprite2D.new()
		deco.texture=load("res://Assets/02_Environments/02_ice_kingdom/tiles/decor_%02d.png"%(2+index%3))
		deco.position=Vector2(x,503)
		deco.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		group.add_child(deco)
	for x in [460,524,588]:
		var icicle:=Sprite2D.new()
		icicle.texture=load("res://Assets/02_Environments/02_ice_kingdom/tiles/decor_03.png")
		icicle.position=Vector2(x,423)
		icicle.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		group.add_child(icicle)

func _unlock_first() -> void:
	first_unlocked=true
	first_crank.set_deferred("monitoring",true)
	$SwitchIndicator.modulate=Color(0.65,1,0.7)
	$SwitchHint.text="V Interruptor acionado — manivela liberada"

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	tunnel.update_prompt(cake)
	anchor.update_prompt(cake)
	crank.update_prompt(fionna)
	if first_unlocked: first_crank.update_prompt(fionna)
	else: first_crank.prompt.text="Cake: acione o interruptor após o túnel."
	if cake.crawling and cake.position.x>470 and cake.position.x<590: tunnel_visited=true
	if not first_unlocked and $SwitchArea.overlaps_body(cake) and tunnel_visited:
		$SwitchHint.text=("E" if cake.player_id==1 else "Enter")+": liberar a manivela"
	if Input.is_action_just_pressed(cake.get_interact_action()) and not cake.movement_locked:
		if not first_unlocked and tunnel_visited and $SwitchArea.overlaps_body(cake) and cake.has_ability(&"crawl"):
			_unlock_first()
		elif cake.crawling: cake.request_stand()
		else: tunnel.interact(cake)
	elif Input.is_action_just_pressed(cake.get_ability_action()) and not cake.movement_locked: anchor.activate(cake)
	if not is_instance_valid(fionna.interaction_owner) and Input.is_action_just_pressed(fionna.get_interact_action()):
		if first_unlocked and first_crank.can_interact(fionna): first_crank.interact(fionna)
		elif crank.can_interact(fionna): crank.interact(fionna)

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint() or completed: return
	if not checkpoint_active and first_crank.solved and $FirstPlatform.extended and cake.position.x>990 and fionna.position.x>990:
		checkpoint_active=true
		_starts=[Vector2(1024,487),Vector2(1088,487)]
		checkpoint_flag.texture=load("res://Assets/03_Objects_and_Puzzles/sprites/checkpoint_on.png")
	if is_instance_valid(final_crystal):
		var available: bool=crank.solved and $ExtendPlatform.extended
		final_crystal.monitoring=available
		final_crystal.modulate=Color.WHITE if available else Color(0.45,0.55,0.65,1)
	if cake.position.y>720 or fionna.position.y>720: recover_pair()

func recover_pair() -> void:
	cake.reset_after_recovery()
	fionna.reset_after_recovery()
	cake.position=_starts[0]
	fionna.position=_starts[1]
	cake.velocity=Vector2.ZERO
	fionna.velocity=Vector2.ZERO
	if not first_crank.solved: $PushBlock.reset_to_start()
	recovery_count+=1

func _unhandled_key_input(event: InputEvent) -> void:
	if Engine.is_editor_hint() or not event is InputEventKey or not event.pressed or event.echo: return
	if event.keycode==KEY_F2:
		get_viewport().set_input_as_handled()
		get_tree().reload_current_scene()
	elif event.keycode==KEY_ESCAPE:
		if is_instance_valid(cake.pose_owner): cake.pose_owner.cancel_immediately()
		elif cake.crawling: cake.request_stand()
		if is_instance_valid(fionna.interaction_owner): fionna.interaction_owner.cancel()

func _setup_finish() -> void:
	$CrystalReserved.hide();$ExitReserved.hide();$FinalHint.hide()
	$SwitchIndicator.position.y=488
	final_crystal=load("res://crystal.tscn").instantiate()
	final_crystal.name="FriendshipCrystal";final_crystal.position=Vector2(2112,479)
	add_child(final_crystal)
	final_crystal.monitoring=false
	final_crystal.collected.connect(func():crystal_collected=true)
	final_exit=load("res://cooperative_exit.tscn").instantiate()
	final_exit.name="CooperativeExit";final_exit.position=Vector2(2224,487)
	final_exit.crystal_path=NodePath("../FriendshipCrystal")
	add_child(final_exit)
	final_exit.level_completed.connect(_complete_level)
	checkpoint_flag=Sprite2D.new();checkpoint_flag.name="CheckpointFlag"
	checkpoint_flag.texture=load("res://Assets/03_Objects_and_Puzzles/sprites/checkpoint_off.png")
	checkpoint_flag.position=Vector2(1088,487);add_child(checkpoint_flag)

func _complete_level() -> void:
	if completed:return
	completed=true;completion_count+=1
	cake.reset_after_recovery();fionna.reset_after_recovery()
	cake.movement_locked=true;fionna.movement_locked=true
	final_exit.completion_label.hide()
	$Instructions/Text.text="Cristal recuperado! Vocês atravessaram juntos.\nF2: repetir • Fases: escolher outra aventura."
