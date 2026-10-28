extends "res://phase_hud.gd"
## The received scenes omit this optional child. Keep their own instructions.
func _enter_tree() -> void:
	if not has_node("JakeBridgeHint"):
		var unused_bridge_hint := Label.new()
		unused_bridge_hint.name = "JakeBridgeHint"
		unused_bridge_hint.hide()
		add_child(unused_bridge_hint)

func _ready() -> void:
	var received_hints: String = $Hints.text
	super._ready()
	hint_label.text = received_hints
