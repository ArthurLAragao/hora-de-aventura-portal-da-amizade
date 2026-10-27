extends "res://pressure_plate.gd"
## Restriction belongs to a character capability, never its P1/P2 assignment.
@export var required_ability: StringName = &""
func _is_accepted(body: Node2D) -> bool:
	if required_ability!=&"": return body is CoopPlayer and body.has_ability(required_ability)
	return super._is_accepted(body)

func _set_visual(pressed: bool) -> void:
	super._set_visual(pressed)
	plate_sprite.position=Vector2(0,-3 if pressed else -9)
	plate_sprite.z_index=-1
	plate_sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
