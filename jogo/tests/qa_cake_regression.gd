extends "res://tests/verify_cake.gd"
## Keep original movement/tunnel/full service route checks. The old no-displacement
## and instant-cancel assertions are superseded by the user-authorized assisted walk.
## qa_bridge_matrix validates the replacement, including physical support and bounded retraction.
func _poses(_slot: int) -> void:
	pass
