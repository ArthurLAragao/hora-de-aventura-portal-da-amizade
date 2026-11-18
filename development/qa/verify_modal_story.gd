extends "res://tests/journey_driver.gd"
const KEYS={1:"finn_player_id",2:"cake_player_id",3:"lead_player_id",4:"lead_player_id",5:"lead_player_id",6:"primary_player_id"}
func key(code: Key) -> void:
	var event:=InputEventKey.new();event.keycode=code;event.physical_keycode=code;event.pressed=true;Input.parse_input_event(event);await frames(2)
	event=InputEventKey.new();event.keycode=code;event.physical_keycode=code;event.pressed=false;Input.parse_input_event(event);await frames(16)
func run() -> void:
	auto_dismiss_dialogue=false;root.size=viewport_size
	for slot in [1,2]:
		for phase in range(1,7):
			await fresh("res://level_%d.tscn"%phase,slot,KEYS[phase])
			var story=level.get_node("FriendshipStory")
			check("F%d abre conversa antes de liberar o mundo"%phase,story.modal_active and paused and story.armed)
			var actors:=get_nodes_in_group("players");var before: Vector2=actors[0].position
			Input.action_press("p1_right");Input.action_press("p2_jump");await frames(20)
			check("F%d ambos ficam imóveis durante leitura"%phase,paused and actors[0].position==before)
			release();await frames(15)
			await key(KEY_TAB)
			check("F%d Tab avança uma fala, sem fechar ou mover"%phase,story.current_line==1 and story.modal_active and paused)
			if slot==1:await capture("dialogue-phase%d"%phase)
			await key(KEY_ESCAPE)
			check("F%d Pular restaura pausa e controles"%phase,not paused and not story.modal_active and not story.card.is_visible_in_tree())
			await frames(35)
			check("F%d nenhuma caixa avulsa surge após leitura"%phase,not story.modal_active)
			await key(KEY_F3)
			check("F%d releitura opcional também é modal"%phase,story.modal_active and paused)
			await key(KEY_ESCAPE)
			check("F%d fechar releitura não deixa pausa"%phase,not paused)
	await fresh("res://level_1.tscn",1,"finn_player_id")
	var story=level.get_node("FriendshipStory")
	for size in [Vector2i(800,450),Vector2i(1024,768),Vector2i(1280,720),Vector2i(1920,1080)]:
		root.size=size;await frames(10)
		check("conversa e retratos cabem em %s"%size,Rect2(Vector2.ZERO,root.get_visible_rect().size).grow(1).encloses(story.card.get_global_rect()) and story.card.get_global_rect().encloses(story.dialogue.get_global_rect()))
		await capture("dialogue-%dx%d"%[size.x,size.y])
	root.size=viewport_size;await frames(10)
	Input.action_press("p1_right");story.skip();await frames(8)
	check("fechamento espera soltar entradas",paused and story.closing)
	release();await frames(12);check("soltar libera sem ação residual",not paused and not story.modal_active)
	await fresh("res://level_3.tscn",2,"lead_player_id");story=level.get_node("FriendshipStory")
	await key(KEY_TAB)
	var foot_y: float=level.marceline.position.y
	var space:=InputEventKey.new();space.keycode=KEY_SPACE;space.physical_keycode=KEY_SPACE;space.pressed=true;Input.parse_input_event(space);await frames(10)
	check("última fala não injeta salto ao segurar Espaço",story.closing and paused and level.marceline.position.y==foot_y)
	space=InputEventKey.new();space.keycode=KEY_SPACE;space.physical_keycode=KEY_SPACE;space.pressed=false;Input.parse_input_event(space);await frames(25)
	check("soltar Espaço retoma sem salto residual",not paused and level.marceline.is_on_floor() and level.bmo.is_on_floor())
	await fresh("res://level_1.tscn",2,"finn_player_id")
	var old_id: int=level.get_instance_id();await key(KEY_F2);level=current_scene;await frames(25)
	check("F2 na conversa reinicia com os papéis preservados",level.get_instance_id()!=old_id and level.finn.player_id==2 and level.get_node("FriendshipStory").modal_active and not level.tutorial_solved)
	await key(KEY_ESCAPE)
	await finish("Conversas modais: leitura, teclas separadas e retomada segura")
