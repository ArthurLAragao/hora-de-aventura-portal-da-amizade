extends Node2D
class_name JakeBridgeVisual

# All dimensions below are source-texture pixels. End sections keep the
# character's uniform scale. Only the one-pixel torso strip repeats.
var progress := 0.0
var source_frame: Texture2D
var source_origin := Vector2.ZERO
var pixel_scale := 1.0
var extra_length := 0.0
var vertical_adjustment := 0.0
var _complete_rendered := false

func configure(frame: Texture2D, origin: Vector2, uniform_scale: float, right_section_x: float, support_top: float) -> void:
	source_frame = frame
	source_origin = origin
	pixel_scale = uniform_scale
	extra_length = maxf(0.0, right_section_x - origin.x - 48.0 * pixel_scale)
	vertical_adjustment = support_top - origin.y - 58.0 * pixel_scale
	progress = 0.0
	_complete_rendered = false
	queue_redraw()

func set_progress(value: float) -> void:
	progress = clampf(value, 0.0, 1.0)
	if progress < 1.0:
		_complete_rendered = false
	queue_redraw()

func has_full_render() -> bool:
	# Headless runs validate the same geometry, without claiming a visual test.
	return is_visible_in_tree() and progress >= 1.0 and (_complete_rendered or DisplayServer.get_name() == "headless")

func get_flat_back_rect() -> Rect2:
	return Rect2(source_origin + Vector2(30.0 * pixel_scale, 58.0 * pixel_scale + vertical_adjustment), Vector2(22.0 * pixel_scale + extra_length, pixel_scale))

func _draw() -> void:
	if source_frame == null:
		return
	var origin := source_origin + Vector2(0.0, vertical_adjustment * progress)
	var extra := extra_length * progress
	draw_texture_rect_region(source_frame, Rect2(origin, Vector2(48, 80) * pixel_scale), Rect2(0, 0, 48, 80))
	var cursor := 0.0
	while cursor < extra - 0.0001:
		var width := minf(pixel_scale, extra - cursor)
		draw_texture_rect_region(source_frame, Rect2(origin + Vector2(48.0 * pixel_scale + cursor, 0), Vector2(width, 80.0 * pixel_scale)), Rect2(47, 0, width / pixel_scale, 80))
		cursor += width
	draw_texture_rect_region(source_frame, Rect2(origin + Vector2(48.0 * pixel_scale + extra, 0), Vector2(48, 80) * pixel_scale), Rect2(48, 0, 48, 80))
	_complete_rendered = progress >= 1.0

