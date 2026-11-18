extends Node2D
## Acabamento em PNG para placas da caverna/oficina, mantendo a Area2D original.
@export var region:=3
var plate: PressurePlate
var artwork: Sprite2D
var completed:=false
var previous:=-1
func _ready() -> void:
	plate=get_parent();plate.plate_sprite.hide()
	artwork=preload("res://scripts/scenery/mechanism_sprite.gd").plate(self,region)
func _process(_delta: float) -> void:
	var owner_node:=plate.get_parent()
	completed=owner_node.confirmation_solved if region==3 else owner_node.get_node("Gate").is_open
	var state: int=preload("res://scripts/scenery/mechanism_sprite.gd").state(plate.is_active(),completed)
	if state!=previous:previous=state;artwork.frame=state
