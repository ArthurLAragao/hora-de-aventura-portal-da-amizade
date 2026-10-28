extends "res://imported_phase_runtime.gd"

const Terminal = preload("res://tests/bmo_terminal.gd")

@onready var finn: CoopPlayer = $Players/Finn
@onready var bmo: CoopPlayer = $Players/BMO
@onready var energy_terminal: Terminal = $EnergyTerminal
@onready var energy_gate: Node = $EnergyGate

func _ready() -> void:
	configure_imported_phase()
	finn.player_id = 1
	finn.set_meta("player_id", 1)
	bmo.player_id = 2
	bmo.set_meta("player_id", 2)


func _process(_delta: float) -> void:
	if is_instance_valid(energy_terminal):
		energy_terminal.update_prompt(bmo)

	var owner := bmo.get("interaction_owner") as Node
	if is_instance_valid(owner):
		if owner.has_method("process_operator_input"):
			owner.call("process_operator_input")
		return

	if Input.is_action_just_pressed(bmo.get_interact_action()):
		if is_instance_valid(energy_terminal):
			energy_terminal.interact(bmo)

func _unhandled_key_input(event: InputEvent) -> void:
	super._unhandled_key_input(event)
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_ESCAPE:
		var owner := bmo.get("interaction_owner") as Node
		if is_instance_valid(owner) and owner.has_method("cancel"):
			owner.call("cancel")
