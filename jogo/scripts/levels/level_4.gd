extends "res://scripts/levels/imported_phase_runtime.gd"

@export_range(1,2) var lead_player_id:=1

const Terminal = preload("res://mechanisms/bmo_terminal.gd")

var carrier
var transport_terminal
var connections

@onready var finn: CoopPlayer = $Players/Finn
@onready var bmo: CoopPlayer = $Players/BMO
@onready var energy_terminal: Terminal = $EnergyTerminal
@onready var energy_gate: Node = $EnergyGate

## Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: transporte e energia da Fase 4.
func _ready() -> void:
	configure_imported_phase()
	_setup_workshop()
	finn.player_id = lead_player_id
	finn.set_meta("player_id", lead_player_id)
	bmo.player_id = 3-lead_player_id
	bmo.set_meta("player_id", bmo.player_id)


## Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: transporte e energia da Fase 4.
func _process(_delta: float) -> void:
	if not carrier.requested:$TrunkPuzzle/Log.settled=carrier.loaded()
	if carrier.arrived and not $TrunkPuzzle/Gate.is_open and $TrunkPuzzle/Log.global_position.x<480:
		if carrier.reset_if_clear():
			transport_terminal.energized=false
			transport_terminal.sprite.texture=load("res://Assets/03_Objects_and_Puzzles/sprites/terminal_off.png")
			transport_terminal.status.text="Plataforma restaurada."
	transport_terminal.update_prompt(bmo)
	if not carrier.loaded() and not transport_terminal.energized:
		transport_terminal.prompt.text="Finn: coloque o bloco no centro da plataforma." if transport_terminal.overlaps_body(bmo) else ""

	if is_instance_valid(energy_terminal):
		energy_terminal.update_prompt(bmo)
		if not connections.solved() and energy_terminal.overlaps_body(bmo):energy_terminal.prompt.text="Finn: alinhe as duas conexões."

	var owner := bmo.get("interaction_owner") as Node
	if is_instance_valid(owner):
		if owner.has_method("process_operator_input"):
			owner.call("process_operator_input")
		return

	if Input.is_action_just_pressed(bmo.get_interact_action()):
		if transport_terminal.can_interact(bmo) and carrier.loaded():
			transport_terminal.interact(bmo)
		elif connections.solved() and is_instance_valid(energy_terminal):
			energy_terminal.interact(bmo)

## Trata comandos contextuais de teclado não consumidos pela interface. Contexto: transporte e energia da Fase 4.
func _unhandled_key_input(event: InputEvent) -> void:
	super._unhandled_key_input(event)
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_ESCAPE:
		var owner := bmo.get("interaction_owner") as Node
		if is_instance_valid(owner) and owner.has_method("cancel"):
			owner.call("cancel")

## Conecta transportador, bloco e terminais às referências da oficina.
func _setup_workshop() -> void:
	var ground: TileMapLayer=$TileMapLayer
	for cell in ground.get_used_cells():
		if cell.x>=18 and cell.x<=21:ground.erase_cell(cell)
	var log_body: PushBlock=$TrunkPuzzle/Log
	log_body.require_support=true
	$TrunkPuzzle/Plate.position=Vector2(204,4)
	var plate_sprite: Sprite2D=$TrunkPuzzle/Plate/Sprite2D
	var used:=plate_sprite.texture.get_image().get_used_rect()
	plate_sprite.position.y=-(used.end.y-plate_sprite.texture.get_height()*0.5)
	$TrunkPuzzle/Gate.position.x=348
	$Checkpoint.position.x=1024
	carrier=AnimatableBody2D.new();carrier.set_script(load("res://scripts/puzzles/workshop_carrier.gd"))
	carrier.name="BlockCarrier";carrier.block=log_body;carrier.process_priority=-10
	add_child(carrier)
	transport_terminal=energy_terminal.duplicate(4) as Area2D
	transport_terminal.name="TransportTerminal";transport_terminal.position=Vector2(376,352)
	transport_terminal.gate_path=NodePath();transport_terminal.indicator_path=NodePath();transport_terminal.battery_path=NodePath()
	add_child(transport_terminal)
	transport_terminal.status.hide()
	transport_terminal.activated.connect(carrier.start_route)
	connections=Node2D.new();connections.set_script(load("res://scripts/puzzles/workshop_connections.gd"))
	connections.name="SpatialConnections";add_child(connections)
	$Battery.position=Vector2(1360,352)
	$EnergyIndicator.position=Vector2(1576,352)
