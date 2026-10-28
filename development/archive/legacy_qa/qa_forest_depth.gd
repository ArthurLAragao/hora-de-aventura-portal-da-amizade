extends "res://tests/verify_journey_1.gd"
## Runs the unchanged input-driven route and inspects actual background coverage along it.
func capture(name: String) -> void:
	await super.capture(name)
	var panorama=level.get_node("Background/Panorama")
	var extent: Vector2=panorama.texture.get_size()*panorama.scale*0.5
	var bounds:=Rect2(panorama.position-extent,extent*2.0)
	check(name+": background covers the reference canvas through the real camera route",bounds.encloses(Rect2(0,0,1152,648)))
	check(name+": panorama keeps its aspect ratio",is_equal_approx(panorama.scale.x,panorama.scale.y))
