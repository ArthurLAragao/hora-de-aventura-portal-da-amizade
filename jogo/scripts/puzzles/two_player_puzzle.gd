extends Node
class_name TwoPlayerPuzzle

signal puzzle_solved

@onready var player_one_plate: PressurePlate = $FinnPlate
@onready var player_two_plate: PressurePlate = $JakePlate
@onready var gate_to_open: CoopGate = $Gate

var solved := false

## Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: confirmação simultânea em duas placas.
func _ready() -> void:
	player_one_plate.activation_changed.connect(_check_solution)
	player_two_plate.activation_changed.connect(_check_solution)

## Combina as condições das placas e libera o resultado quando a cooperação é satisfeita.
func _check_solution(_active: bool) -> void:
	if solved or not player_one_plate.is_active() or not player_two_plate.is_active():
		return
	solved = true
	gate_to_open.open_gate()
	puzzle_solved.emit()
