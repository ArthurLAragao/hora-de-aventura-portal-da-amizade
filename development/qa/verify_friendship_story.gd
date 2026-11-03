extends "res://tests/journey_driver.gd"
## Preparações isoladas de contexto; nenhuma solução injetada é evidência de percurso.
const ROLES={1:"finn_player_id",2:"cake_player_id",3:"lead_player_id",4:"lead_player_id",5:"lead_player_id",6:"primary_player_id"}

## Envia teclas reais ao roteamento de entrada, inclusive antes da navegação de foco da UI.
func key(code: Key) -> void:
	var event:=InputEventKey.new();event.keycode=code;event.pressed=true;Input.parse_input_event(event);await frames(2)
	event=InputEventKey.new();event.keycode=code;event.pressed=false;Input.parse_input_event(event);await frames(2)

## Prepara a primeira conquista de cada fase exclusivamente para inspecionar a reação narrativa.
func first_success(number: int) -> void:
	match number:
		1:level.tutorial_solved=true
		2:level._unlock_first()
		3:level.get_node("MusicGate").open_gate()
		4:level.get_node("TrunkPuzzle/Log").position.x=512;level.carrier.arrived=true
		5:level.solved[0]=true
		6:level._repair(0)
	await frames(14)

## Confere leitura, controles, contexto e descarte seguro de conversas nas seis fases.
func run() -> void:
	root.size=viewport_size
	for slot in [1,2]:
		for number in range(1,7):
			await fresh("res://level_%d.tscn"%number,slot,ROLES[number])
			var story=level.get_node("FriendshipStory")
			check("F%d: introdução contextual presente"%number,story.card.visible and story.current_id=="intro" and story.emitted==["intro"])
			var viewport:=root.get_visible_rect().size
			var bounds: Rect2=story.card.get_global_rect()
			check("F%d: cartão dentro da tela e texto sem corte"%number,Rect2(Vector2.ZERO,viewport).encloses(bounds) and story.dialogue.get_line_count()==story.dialogue.get_visible_line_count() and story.dialogue.size.y>=story.dialogue.get_minimum_size().y-1)
			var actors=get_nodes_in_group("players")
			check("F%d: narrativa não pausa nem bloqueia a dupla"%number,not paused and actors.size()==2 and actors.all(func(a):return not a.movement_locked))
			var character: String=story.current_lines[0][0]
			var active=actors.filter(func(a):return String(a.character_id)==character)[0]
			check("F%d: retrato e papel correspondem ao personagem"%number,story.portrait.texture!=null and story.speaker.text.ends_with("P%d"%active.player_id))
			await capture("story-f%d-intro"%number)
			var start: float=actors[0].position.x;var other: float=actors[1].position.x
			await walk(actors[0],start+24)
			check("F%d: movimento independente durante conversa"%number,actors[0].position.x>start+15 and absf(actors[1].position.x-other)<1)
			await key(KEY_TAB)
			check("F%d: Tab avança sem usar interação ou salto"%number,story.current_line==1 and story.current_id=="intro" and not Input.is_action_pressed(action(actors[0],"interact")))
			await key(KEY_F3)
			check("F%d: releitura opcional começa pela primeira fala"%number,story.current_id=="replay" and story.current_line==0)
			if slot==1:
				await frames(int(story.remaining*60)+12)
				check("F%d: avanço automático respeita tempo de leitura"%number,story.current_line==1)
			await first_success(number)
			check("F%d: conquista aciona uma fala sem duplicação"%number,story.emitted.count("first")==1)
			await frames(30)
			check("F%d: evento não repete a cada quadro"%number,story.emitted.count("first")==1 and story.pending.size()<=2)
			if number==3:
				level.bmo.position=Vector2(1050,352);await frames(15)
				await tap(level.bmo,"interact")
				check("painel de símbolos tem prioridade visual",level.symbol_terminal.panel_open and not story.card.visible and not story.canvas.visible)
				await key(KEY_ESCAPE)
				check("cancelamento do painel preserva controles",not level.symbol_terminal.panel_open and not level.bmo.movement_locked)
				await key(KEY_F3)
				check("releitura continua disponível após painel",story.card.visible)
			if number==5:
				var before: int=level.recovery_count
				level.marceline.position.y=760;await frames(15)
				check("recuperação oferece incentivo sem repetir introdução",level.recovery_count==before+1 and story.emitted.has("retry") and story.emitted.count("intro")==1 and level.solved[0])
				await capture("story-retry")
			if number==6:
				level._advance_pair(1);await until(func():return not level._transitioning,180);await frames(14)
				check("segunda dupla recebe conversa própria após transição",story.current_id=="pair1" and story.speaker.text.begins_with("Fionna") and story.canvas.visible)
				await capture("story-portal-pair1")
				level._repair(1);level._advance_pair(2);await until(func():return not level._transitioning,180);await frames(14)
				check("terceira dupla substitui contexto anterior",story.current_id=="pair2" and story.speaker.text.begins_with("Marceline") and story.emitted.count("pair2")==1)
				await capture("story-portal-pair2")
				level.completion_count=1;await frames(14)
				check("conclusão final não fica coberta pela conversa",not story.card.visible)
			await key(KEY_F2);level=current_scene;await frames(20);story=level.get_node("FriendshipStory")
			check("F%d: reinício limpa fila e retoma história inicial"%number,story.current_id=="intro" and story.emitted==["intro"] and not paused)
	await finish("Conteúdo da amizade: apresentação e limites")
