extends Node2D
## Isolated validation room: does not replace a phase or change its fixed pair.
@export_range(1, 2) var marceline_player_id: int = 1

@onready var marceline: CoopPlayer = $Marceline
@onready var reference: CoopPlayer = $Finn
var recovery_count := 0

func _ready() -> void:
	DisplayServer.window_set_title("Marceline — teste P1/P2, flutuação e música")
	marceline.player_id = marceline_player_id
	marceline.set_meta("player_id", marceline_player_id)
	reference.player_id = 3 - marceline_player_id
	reference.set_meta("player_id", 3 - marceline_player_id)
	var terrain := $Terrain as TileMap
	for column in range(36):
		for row in range(28, 33):
			terrain.set_cell(0, Vector2i(column,row), 1, Vector2i(1,0 if row == 28 else 1))
	for column in range(2,11):
		terrain.set_cell(0, Vector2i(column,14), 1, Vector2i(1,0))
		terrain.set_cell(0, Vector2i(column,15), 1, Vector2i(1,1))
	for column in range(8,11):
		terrain.set_cell(0, Vector2i(column,9), 1, Vector2i(1,1))
	for wall_column in [0,35]:
		for row in range(8,28):
			terrain.set_cell(0, Vector2i(wall_column,row), 1, Vector2i(1,1))
	for platform in [Vector2i(15,26),Vector2i(19,24),Vector2i(23,22)]:
		for column in range(platform.x, platform.x+2):
			terrain.set_cell(0, Vector2i(column,platform.y), 1, Vector2i(1,0))
	var mc := "A/D: andar | Espaço/W: pular | Q: flutuar no ar | E: música" if marceline_player_id == 1 else "Setas: andar | Cima: pular | Shift direito: flutuar no ar | Enter: música"
	var fc := "Setas e Cima" if marceline_player_id == 1 else "A/D e Espaço/W"
	$Instructions/Text.text = "TESTE MARCELINE — P%d | %s\nFinn (P%d): %s — referência de escala e controles separados.\nFlutuação: até %.1f s no ar; solte para parar. Recarrega ao pousar. F2 reinicia.\nTrocar P1/P2: raiz da cena > Marceline Player Id > 1 ou 2 > F6." % [marceline_player_id,mc,reference.player_id,fc,float(marceline.get("float_duration"))]

func _physics_process(_delta: float) -> void:
	if marceline.position.y > 740 or reference.position.y > 740:
		recover_pair()

func recover_pair() -> void:
	marceline.call("reset_after_recovery")
	marceline.position = Vector2(160,245)
	reference.position = Vector2(224,245)
	reference.velocity = Vector2.ZERO
	recovery_count += 1

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F2:
		get_tree().reload_current_scene()
