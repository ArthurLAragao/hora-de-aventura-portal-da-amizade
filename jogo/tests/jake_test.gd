extends Node2D
## Practice only. The production level and checkpoint remain untouched.
@export_range(1, 2) var jake_player_id: int = 2

func _ready() -> void:
	DisplayServer.window_set_title("Jake - teste de ponte P1/P2")
	var terrain := $Terrain as TileMap
	for column in range(36):
		if column >= 14 and column <= 18:
			continue
		for row in range(14, 21):
			terrain.set_cell(0, Vector2i(column, row), 1, Vector2i(1, 0 if row == 14 else 1))
	for column in range(1, 5):
		terrain.set_cell(0, Vector2i(column, 11), 1, Vector2i(1, 0))
		terrain.set_cell(0, Vector2i(column, 12), 1, Vector2i(1, 1))
	$Jake.player_id = jake_player_id
	$Jake.set_meta("player_id", jake_player_id)
	$Finn.player_id = 3 - jake_player_id
	$Finn.set_meta("player_id", 3 - jake_player_id)
	var jake_controls := "A/D | Espaco ou W | Q: ponte" if jake_player_id == 1 else "Setas | Cima | Shift direito: ponte"
	var finn_controls := "A/D | Espaco ou W | E: alavanca" if jake_player_id == 2 else "Setas | Cima | Enter: alavanca"
	$Instructions/Text.text = "TESTE JAKE - identidade independente de P1/P2\nJake (P%d): %s\nFinn (P%d): %s\nJake segura a ponte no chao junto da ancora. Finn atravessa e libera a passagem.\nF2 reinicia. Para inverter papeis: raiz da cena > Jake Player Id > 1 ou 2 > F6." % [jake_player_id, jake_controls, 3 - jake_player_id, finn_controls]

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F2:
		get_tree().reload_current_scene()
