extends Node2D
## Compatibilidade com a composição atual: a placa da jornada já possui seu atlas.
## Sem segundo desenho sobreposto e sem alterar a Area2D.
func _ready() -> void:
	get_parent().self_modulate=Color.WHITE
