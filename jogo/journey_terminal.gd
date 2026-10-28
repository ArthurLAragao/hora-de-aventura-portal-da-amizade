extends "res://tests/bmo_terminal.gd"
## Scene-specific prerequisite; the shared panel, symbols, cancellation and animation stay intact.
func can_interact(actor: CoopPlayer) -> bool:
	return bool(get_parent().get("clue_revealed")) and monitoring and super.can_interact(actor)

func _ready() -> void:
	super._ready()
	# Keep Marceline and the three clue forms visible on the shared camera.
	panel.position=Vector2(704,244)
