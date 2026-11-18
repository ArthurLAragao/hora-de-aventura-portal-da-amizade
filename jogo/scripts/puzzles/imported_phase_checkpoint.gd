extends "res://scripts/puzzles/checkpoint.gd"
## Only the imported levels use this rule; the approved Phase 1 rule stays unchanged.
@export var progress_gate_path: NodePath

## Registra a entrada de um corpo elegível na área e reavalia a ação local. Contexto: checkpoint das fases integradas.
func _on_body_entered(body: Node2D) -> void:
	if activated or not _accepting_entries or _recovery_in_progress:
		return
	if not body is CoopPlayer or not overlaps_body(body):
		return
	var progress_gate := get_node_or_null(progress_gate_path) as CoopGate
	if progress_gate == null or not progress_gate.is_open:
		return
	activated = true
	checkpoint_sprite.texture = active_texture
	activation_sfx.play()
	checkpoint_activated.emit()
