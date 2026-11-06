extends Node2D
@export_range(1,2) var cake_player_id: int = 1
@onready var cake: CoopPlayer = $Cake
@onready var fionna: CoopPlayer = $Fionna
@onready var tunnel: Node2D = $Tunnel
@onready var anchor: Area2D = $Anchor
@onready var crank: Area2D = $Crank
var recovery_count := 0

func _ready() -> void:
	DisplayServer.window_set_title("Cake — túnel e ponte funcional")
	cake.player_id=cake_player_id
	cake.set_meta("player_id",cake.player_id)
	fionna.player_id=3-cake_player_id
	fionna.set_meta("player_id",fionna.player_id)
	var terrain := $Terrain as TileMap
	for column in 36:
		for row in range(25,33): terrain.set_cell(0,Vector2i(column,row),1,Vector2i(1,0 if row==25 else 1))
	for column in [0,35]:
		for row in range(7,25): terrain.set_cell(0,Vector2i(column,row),1,Vector2i(1,1))
	for column in range(10,15): $Roof.set_cell(0,Vector2i(column,23),1,Vector2i(1,1))
	for step in [Vector2i(23,23),Vector2i(25,21),Vector2i(27,19)]:
		for column in range(step.x,step.x+2): terrain.set_cell(0,Vector2i(column,step.y),1,Vector2i(1,0))
	for column in range(31,35):
		for row in range(19,25): terrain.set_cell(0,Vector2i(column,row),1,Vector2i(1,0 if row==19 else 1))
	var keys:="A/D: andar · Espaço/W: saltar · E: túnel · Q: ponte" if cake_player_id==1 else "←/→: andar · ↑: saltar · Enter: túnel · Shift direito: ponte"
	var fk:="←/→ e ↑ · Enter: manivela" if fionna.player_id==2 else "A/D e Espaço/W · E: manivela"
	$Instructions/Text.text="CAKE P%d — %s\nFionna P%d — %s · Esc cancela · F2 reinicia.\nTúnel: interaja e ande; não salta rastejando. Retorna à postura normal em local livre.\nCake sustenta a ponte. Fionna atravessa, gira a manivela e libera a passagem permanente." % [cake.player_id,keys,fionna.player_id,fk]

func _process(_delta: float) -> void:
	tunnel.call("update_prompt",cake)
	if is_instance_valid(anchor): anchor.call("update_prompt",cake)
	if is_instance_valid(crank):
		crank.call("update_prompt",fionna)
		if not is_instance_valid(fionna.get("interaction_owner")) and Input.is_action_just_pressed(fionna.get_interact_action()): crank.call("interact",fionna)
	if cake.movement_locked: return
	if Input.is_action_just_pressed(cake.get_interact_action()):
		if cake.get("crawling"): cake.call("request_stand")
		else: tunnel.call("interact",cake)
		return
	if is_instance_valid(anchor) and Input.is_action_just_pressed(cake.get_ability_action()): anchor.call("activate",cake)

func _physics_process(_delta: float) -> void:
	if cake.position.y>740 or fionna.position.y>740: recover_pair()

func recover_pair() -> void:
	cake.call("reset_after_recovery")
	fionna.call("reset_after_recovery")
	cake.position=Vector2(256,465)
	fionna.position=Vector2(160,465)
	cake.velocity=Vector2.ZERO
	fionna.velocity=Vector2.ZERO
	recovery_count+=1

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	if event.keycode==KEY_F2: get_tree().reload_current_scene()
	elif event.keycode==KEY_ESCAPE:
		if is_instance_valid(cake.get("pose_owner")): cake.get("pose_owner").call("cancel_immediately")
		elif cake.get("crawling"): cake.call("request_stand")
		var owner:=fionna.get("interaction_owner") as Node
		if is_instance_valid(owner) and owner.has_method("cancel"): owner.call("cancel")
