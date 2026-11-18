extends Node2D
@export_range(1,2) var fionna_player_id: int = 1
@onready var fionna: CoopPlayer = $Fionna
@onready var finn: CoopPlayer = $Finn
@onready var crank: Area2D = $Crank
@onready var block: PushBlock = $PushBlock
@onready var plate: PressurePlate = $BlockPlate
var recovery_count := 0
var plate_activation_count := 0

func _ready() -> void:
	DisplayServer.window_set_title("Fionna — bloco e manivela — sala de teste")
	fionna.player_id = fionna_player_id
	fionna.set_meta("player_id",fionna.player_id)
	finn.player_id = 3-fionna_player_id
	finn.set_meta("player_id",finn.player_id)
	# Room-only configuration: the existing block also stops before a partner.
	block.collision_mask = 3
	var terrain := $Terrain as TileMap
	for column in 36:
		for row in range(25,33): terrain.set_cell(0,Vector2i(column,row),1,Vector2i(1,0 if row==25 else 1))
	for column in [0,35]:
		for row in range(7,25): terrain.set_cell(0,Vector2i(column,row),1,Vector2i(1,1))
	for column in range(3,7): terrain.set_cell(0,Vector2i(column,20),1,Vector2i(1,1))
	for step in [Vector2i(23,23),Vector2i(25,21),Vector2i(27,19)]:
		for column in range(step.x,step.x+2): terrain.set_cell(0,Vector2i(column,step.y),1,Vector2i(1,0))
	for column in range(31,35):
		for row in range(19,25): terrain.set_cell(0,Vector2i(column,row),1,Vector2i(1,0 if row==19 else 1))
	plate.plate_activated.connect(_on_plate_activated)
	plate.activation_changed.connect(_on_plate_changed)
	var keys := "A/D: andar e empurrar · Espaço/W: saltar · E: manivela · R: restaurar bloco" if fionna_player_id==1 else "←/→: andar e empurrar · ↑: saltar · Enter: manivela · Backspace: restaurar bloco"
	var partner := "←/→ e ↑" if finn.player_id==2 else "A/D e Espaço/W"
	$Instructions/Text.text = "FIONNA P%d — %s\nFinn P%d: %s. Também pode empurrar; não possui a capacidade manivela.\n1. Empurre o bloco até a placa. A porta fica aberta. 2. Acione a manivela e suba os degraus.\nEsc cancela a ação · F2 reinicia · Inspector da raiz: Fionna Player Id = 1 ou 2." % [fionna.player_id,keys,finn.player_id,partner]

func _process(_delta: float) -> void:
	if not is_instance_valid(crank): return
	crank.call("update_prompt",fionna)
	# Push is physical contact + movement, never an E/Enter interaction.
	# Thus the same contextual input has only one eligible receiver.
	if is_instance_valid(fionna.get("interaction_owner")): return
	if Input.is_action_just_pressed(fionna.get_interact_action()): crank.call("interact",fionna)

func _on_plate_activated() -> void:
	plate_activation_count += 1
	$BlockGate.open_gate()

func _on_plate_changed(active: bool) -> void:
	$PlateStatus.text = "✓ Bloco na placa — porta aberta" if active else ("Placa livre — porta permanece aberta" if $BlockGate.is_open else "Placa: somente bloco marcado")

func _physics_process(_delta: float) -> void:
	if fionna.position.y>740 or finn.position.y>740: recover_pair()

func recover_pair() -> void:
	fionna.call("reset_after_recovery")
	fionna.position = Vector2(256,465)
	finn.position = Vector2(160,465)
	finn.velocity = Vector2.ZERO
	finn._interaction_left = 0.0
	finn._jump_buffer_left = 0.0
	finn._coyote_left = 0.0
	recovery_count += 1

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	if event.keycode==KEY_F2: get_tree().reload_current_scene()
	elif event.keycode==KEY_ESCAPE:
		var owner := fionna.get("interaction_owner") as Node
		if is_instance_valid(owner) and owner.has_method("cancel"): owner.call("cancel")
