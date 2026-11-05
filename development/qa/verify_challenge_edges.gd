extends "res://tests/journey_driver.gd"
## Casos isolados: posições e estados abaixo preparam defeitos, não provam percurso.
func key(code: Key) -> void:
	var event:=InputEventKey.new();event.keycode=code;event.pressed=true
	level._unhandled_key_input(event)
	await frames(30);level=current_scene

## Verifica erros de progressão e entradas concorrentes, sem usar as fixtures como percurso.
func run() -> void:
	root.size=viewport_size
	var a: CoopPlayer
	var b: CoopPlayer
	await fresh("res://level_2.tscn",1,"cake_player_id")
	await key(KEY_F2)
	check("F2 da fase 2 preserva Cake P1 e Fionna P2",level.cake.player_id==1 and level.fionna.player_id==2)
	for number in [3,4]:
		await fresh("res://level_%d.tscn"%number,2,"lead_player_id")
		await key(KEY_F2)
		check("F2 da fase %d preserva papéis invertidos"%number,level.lead_player_id==2 and level.get_node("Players").get_child(0).player_id==2)
	await fresh("res://level_2.tscn",1,"cake_player_id")
	level.cake.position=Vector2(1024,420);level.fionna.position=Vector2(1088,420)
	await frames(2)
	level.first_crank.solved=true;level.get_node("FirstPlatform").extended=true
	await frames(1)
	check("checkpoint gelado aguarda pouso da dupla",not level.checkpoint_active)
	await frames(40)
	check("checkpoint gelado aceita reencontro no chão",level.checkpoint_active)
	level._complete_level()
	var at: Vector2=level.cake.position
	Input.action_press(action(level.cake,"right"));await frames(20);release()
	check("Cake não volta a andar após conclusão gelada",level.cake.position.distance_to(at)<1)
	await fresh("res://level_2.tscn",2,"cake_player_id")
	level.crank.solved=true;level.get_node("ExtendPlatform").extended=true
	level.cake.position=Vector2(2112,455);level.fionna.position=Vector2(2040,455)
	await frames(16)
	check("segunda manivela não concede cristal sem primeiro desafio",not level.crystal_collected)
	for slot in [1,2]:
		await fresh("res://level_4.tscn",slot,"lead_player_id")
		a=level.finn;b=level.bmo
		a.position=Vector2(1476,352);b.position=Vector2(1320,352);await frames(12)
		check("fixture de sobreposição real dos dois condutores",level.connections.areas.all(func(area):return area.overlaps_body(a)))
		var before: Array=level.connections.turns.duplicate()
		await capture("circuit-overlap-before")
		await tap(a,"interact")
		var changes:=int(level.connections.turns[0]!=before[0])+int(level.connections.turns[1]!=before[1])
		check("uma entrada gira somente um condutor",changes==1)
		await capture("circuit-overlap-after")
		level.connections.turns.assign([0,0])
		a.position=Vector2(1432,352);b.position=Vector2(1320,352);await frames(12)
		await tap(b,"interact",1)
		check("conexão de BMO está em andamento",level.energy_terminal.pending)
		await tap(a,"interact",1)
		check("circuito não muda durante conexão em andamento",level.connections.solved())
		await key(KEY_ESCAPE)
		check("cancelar conexão devolve controles sem conceder energia",not b.movement_locked and not level.energy_terminal.pending and not level.energy_terminal.energized)
		await tap(a,"interact")
		check("cancelamento permite realinhar circuito",not level.connections.solved() and not level.connections.locked)
		await tap(a,"interact");await tap(b,"interact");await frames(100)
		await tap(b,"interact");await frames(100)
		check("energia conclui uma vez após nova tentativa",level.energy_terminal.energized and level.energy_terminal.activation_count==1 and level.energy_gate.is_open and not b.movement_locked)
	for slot in [1,2]:
		await fresh("res://level_3.tscn",slot,"lead_player_id")
		a=level.marceline;b=level.bmo
		a.position=Vector2(960,352);b.position=Vector2(1050,352);await frames(15)
		await tap(b,"interact")
		check("terminal abre sem confirmação acidental",level.symbol_terminal.panel_open and level.symbol_terminal.entered.is_empty())
		var partner_x: float=a.position.x
		await walk(a,1000)
		check("parceira continua controlável durante painel",a.position.x>partner_x+20 and level.symbol_terminal.panel_open and level.symbol_terminal.entered.is_empty())
		for i in 4:await tap(b,"interact")
		check("sequência errada permite tentar novamente",level.symbol_terminal.attempts==1 and not level.symbol_terminal.solved and level.symbol_terminal.entered.is_empty() and not level.get_node("SymbolGate").is_open)
		await key(KEY_ESCAPE)
		check("Esc fecha painel e devolve controles",not level.symbol_terminal.panel_open and not b.movement_locked)
		await tap(b,"interact")
		await tap(b,"interact");await tap(b,"right");await tap(b,"right");await tap(b,"interact");await tap(b,"left");await tap(b,"interact");await tap(b,"left");await tap(b,"interact")
		check("nova tentativa correta abre somente a porta correspondente",level.symbol_terminal.solved and level.symbol_terminal.activation_count==1 and level.get_node("SymbolGate").is_open and not b.movement_locked)
	await finish("Limites de desafios: reinício, checkpoint e circuito")
