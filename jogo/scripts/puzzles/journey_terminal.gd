extends "res://mechanisms/bmo_terminal.gd"
## Scene-specific prerequisite; the shared panel, symbols, cancellation and animation stay intact.
## Verifica alcance, capacidade e disponibilidade para uma interação contextual.
func can_interact(actor: CoopPlayer) -> bool:
	return bool(get_parent().get("clue_revealed")) and monitoring and super.can_interact(actor)

## Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: terminal de sinal do portal.
func _ready() -> void:
	super._ready()
	# Keep Marceline and the three clue forms visible on the shared camera.
	panel.position=Vector2(704,244)
