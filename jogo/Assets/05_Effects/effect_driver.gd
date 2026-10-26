extends AnimatedSprite2D
## Reusable one-shot effects hide on finish; portal keeps looping.
@export var effect_name: StringName = &"interaction"
@export var autoplay_effect := true

func _ready() -> void:
	animation_finished.connect(func() -> void: hide())
	if autoplay_effect:
		trigger(effect_name)

func trigger(effect: StringName) -> void:
	if not sprite_frames.has_animation(effect):
		return
	show()
	play(effect)
	set_frame_and_progress(0, 0.0)
