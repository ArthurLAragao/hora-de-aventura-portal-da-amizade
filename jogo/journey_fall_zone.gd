extends "res://fall_zone.gd"
## Keep the approved pair recovery, with a floor probe that begins ABOVE a resting foot.
## This avoids resetting a grounded, unresolved log when the ray would start inside terrain.
func _has_floor(body: Node2D,rectangle: Rect2) -> bool:
	for x in [rectangle.position.x+2.0,rectangle.get_center().x,rectangle.end.x-2.0]:
		var start:=Vector2(x,rectangle.end.y-0.25)
		var ray:=PhysicsRayQueryParameters2D.create(start,start+Vector2(0,24.25),1)
		ray.exclude=[body.get_rid()]
		if get_world_2d().direct_space_state.intersect_ray(ray).is_empty(): return false
	return true
