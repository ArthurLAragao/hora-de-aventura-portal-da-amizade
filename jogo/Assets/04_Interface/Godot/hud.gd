extends Control
## The game calls these methods; this scene contains presentation only.
const BASE := "res://Assets/"
const CHARACTERS := [&"finn", &"jake", &"fionna", &"cake", &"marceline", &"bmo"]

## Atualiza os dois retratos com personagens válidos.
func set_players(first: StringName, second: StringName) -> void:
	if CHARACTERS.has(first) and CHARACTERS.has(second):
		$First.texture = load(BASE + "01_Characters/" + first + "/portrait.png")
		$Second.texture = load(BASE + "01_Characters/" + second + "/portrait.png")

## Atualiza o texto do objetivo apresentado na interface.
func set_objective(text: String) -> void:
	$Objective.text = text

## Preenche os seis indicadores conforme a quantidade de cristais coletados.
func set_crystals(amount: int) -> void:
	for i in range(6):
		var filename := "crystal_collected" if i < clampi(amount, 0, 6) else "crystal_empty"
		get_node("Crystal%d" % i).texture = load(BASE + "03_Objects_and_Puzzles/sprites/" + filename + ".png")

