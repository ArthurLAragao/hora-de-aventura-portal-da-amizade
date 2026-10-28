extends Node2D
## Isolated practice area. No production level or checkpoint is changed.

func _ready() -> void:
	DisplayServer.window_set_title("Finn - teste P1 e P2")
	var terrain := $Terrain as TileMap
	for column in range(30):
		for row in range(18, 24):
			terrain.set_cell(0, Vector2i(column, row), 1, Vector2i(1, 0 if row == 18 else 1))
	for column in range(5, 10):
		terrain.set_cell(0, Vector2i(column, 15), 1, Vector2i(1, 0))
		terrain.set_cell(0, Vector2i(column, 16), 1, Vector2i(1, 1))

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F2:
		get_tree().reload_current_scene()
