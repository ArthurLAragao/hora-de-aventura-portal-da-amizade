extends StaticBody2D
class_name PermanentBridge

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var move_sfx: AudioStreamPlayer2D = $MoveSFX

## Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: passagem permanente.
func _ready() -> void:
	visible = false
	collision_layer = 0
	if collision_shape != null:
		collision_shape.disabled = true

## Abre a passagem pelo estado existente do mecanismo, sem duplicar efeitos.
func open_gate() -> void:
	if visible:
		return
	visible = true
	collision_layer = 1
	if collision_shape != null:
		collision_shape.set_deferred("disabled", false)
	move_sfx.play()
