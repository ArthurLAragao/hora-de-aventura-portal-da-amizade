extends Node2D
## Alavanca de quatro poses reais; apenas observa o mecanismo existente.
var lever: Area2D
var sprite: Sprite2D
var previous:=false
var animation_time:=0.0
func _ready() -> void:
	lever=get_parent();lever.get_node("Sprite2D").hide();z_index=1
	sprite=Sprite2D.new();sprite.texture=load("res://Assets/03_Objects_and_Puzzles/cohesion_18_11/lever_forest.png");sprite.hframes=4;sprite.position=Vector2(0,2);sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;add_child(sprite)
func _process(delta: float) -> void:
	if previous!=lever._is_activated:previous=lever._is_activated;animation_time=0.0
	if previous:animation_time+=delta;sprite.frame=mini(3,int(animation_time*12))
	else:sprite.frame=0
