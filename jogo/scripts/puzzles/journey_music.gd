extends "res://mechanisms/music_mechanism.gd"
@export var shelf_path: NodePath=NodePath("../ClueShelf")
## Verifica alcance, capacidade e estado necessários para a ação musical.
func can_play(player: CoopPlayer) -> bool:
	if not is_instance_valid(player) or not player.has_ability(required_ability) or not player.is_on_floor() or not overlaps_body(player): return false
	var shelf=get_node_or_null(shelf_path)
	if shelf==null: return false
	var shape=player.get_node("CollisionShape2D")
	var feet: float=shape.global_position.y+shape.shape.size.y*0.5
	var roof=shelf.get_node("CollisionShape2D")
	return absf(feet-(roof.global_position.y-roof.shape.size.y*0.5))<2.0
## Executa a ativação deste mecanismo e atualiza seu estado.
func activate(player: CoopPlayer) -> bool:
	return super.activate(player) if can_play(player) else false
## Sincroniza texto e disponibilidade do mecanismo com o estado atual.
func _refresh() -> void:
	if status==null: return
	status.text=""
	prompt.hide()
	if activated: return
	for player in _players:
		if can_play(player):
			prompt.text=("E" if player.player_id==1 else "Enter")+": tocar"
			prompt.show()
			return
