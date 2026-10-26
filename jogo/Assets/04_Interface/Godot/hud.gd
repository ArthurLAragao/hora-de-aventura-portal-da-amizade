extends Control
## The game calls these methods; this scene contains presentation only.
const BASE := "res://Assets/"
const CHARACTERS := [&"finn", &"jake", &"fionna", &"cake", &"marceline", &"bmo"]

func set_players(first: StringName, second: StringName) -> void:
	if CHARACTERS.has(first) and CHARACTERS.has(second):
		$First.texture = load(BASE + "01_Characters/" + first + "/portrait.png")
		$Second.texture = load(BASE + "01_Characters/" + second + "/portrait.png")

func set_objective(text: String) -> void:
	$Objective.text = text

func set_crystals(amount: int) -> void:
	for i in range(6):
		var filename := "crystal_collected" if i < clampi(amount, 0, 6) else "crystal_empty"
		get_node("Crystal%d" % i).texture = load(BASE + "03_Objects_and_Puzzles/sprites/" + filename + ".png")

