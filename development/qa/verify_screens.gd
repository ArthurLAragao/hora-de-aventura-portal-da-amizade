extends "res://tests/journey_driver.gd"
## Integração das telas; conclusões preparadas abaixo não são evidência de percurso de fase.
const MENU="res://Assets/04_Interface/Godot/main_menu.tscn"
const GUIDE="res://Assets/04_Interface/Godot/instructions.tscn"
var ui_scene: Control
const ROLES={1:"finn_player_id",2:"cake_player_id",3:"lead_player_id",4:"lead_player_id",5:"lead_player_id",6:"primary_player_id"}

## Troca somente a tela sob teste e libera ações da execução anterior.
func screen(path: String) -> void:
	release()
	if is_instance_valid(ui_scene):ui_scene.queue_free();await frames(4)
	if is_instance_valid(level):stop_test_audio(level);level.queue_free();await frames(4)
	level=null;ui_scene=load(path).instantiate();root.add_child(ui_scene);current_scene=ui_scene;await frames(24)

## Envia teclas pelo roteamento de entrada do Godot, incluindo navegação e confirmação GUI.
func key(code: Key) -> void:
	var e:=InputEventKey.new();e.keycode=code;e.physical_keycode=code;e.pressed=true;Input.parse_input_event(e);await frames(2)
	e=InputEventKey.new();e.keycode=code;e.physical_keycode=code;e.pressed=false;Input.parse_input_event(e);await frames(8)

## Compara textos e botões com seus espaços reservados, detectando corte e crescimento indevido.
func slots_fit(parent: Node) -> bool:
	var okay:=true
	if parent is Control and parent.has_meta("screen_slot") and parent.is_visible_in_tree():
		var slot: Rect2=parent.get_meta("screen_slot")
		if parent.size.x>slot.size.x+1 or parent.size.y>slot.size.y+1:
			print("SLOT_OVERFLOW ",parent.name," ",parent.size," expected ",slot.size);okay=false
	for child in parent.get_children():okay=slots_fit(child) and okay
	return okay

## Confere o enquadramento da composição ajustada, em coordenadas de viewport.
func fits(design: Control) -> bool:
	var bounds:=design.get_global_rect()
	return Rect2(Vector2.ZERO,root.get_visible_rect().size).grow(1).encloses(bounds)

## Prepara o evento final original para testar os botões sem alegar resolver os puzzles.
func finish_fixture(number: int) -> void:
	match number:
		1:level._complete()
		2:level._complete_level()
		3,4:level._on_imported_completion()
		5:level.complete()
	await frames(20)

## Verifica teclado, som, páginas de orientação e adaptação a diferentes janelas.
func menu_cases() -> void:
	await screen(MENU)
	var original:=AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))
	ui_scene.get_node("Design/Buttons/sound").pressed.emit();await frames(4)
	check("som mostra o estado real após alternar",AudioServer.is_bus_mute(0)!=original and ui_scene.sound_state.text==("Som: desligado" if not original else "Som: ligado"))
	AudioServer.set_bus_mute(0,original);ui_scene.update_sound_state()
	for size in [Vector2i(800,450),Vector2i(1024,768),Vector2i(1280,720),Vector2i(1920,1080)]:
		root.size=size;await frames(6)
		check("menu enquadrado em %s"%size,fits(ui_scene.design))
		await capture("menu-%dx%d"%[size.x,size.y])
	root.size=Vector2i(1280,720);await frames(6)
	ui_scene.get_node("Design/Buttons/play").grab_focus();await key(KEY_DOWN)
	check("seta navega para orientações",root.gui_get_focus_owner()==ui_scene.get_node("Design/Buttons/how_to_play"))
	await key(KEY_ENTER);ui_scene=current_scene
	check("Enter abre orientações conectadas ao menu",ui_scene.scene_file_path==GUIDE and ui_scene.active_page==0)
	for size in [Vector2i(800,450),Vector2i(1024,768),Vector2i(1280,720),Vector2i(1920,1080)]:
		root.size=size;await frames(6)
		for page in 3:
			ui_scene.select_page(page);await frames(5)
			check("orientações página %d cabem em %s"%[page,size],fits(ui_scene.design) and slots_fit(ui_scene))
			await capture("guide-page%d-%dx%d"%[page,size.x,size.y])
	await key(KEY_ESCAPE);ui_scene=current_scene
	check("Esc retorna ao menu sem pausa residual",ui_scene.scene_file_path==MENU and not paused)
	ui_scene.get_node("Design/Buttons/play").pressed.emit();await frames(10);ui_scene=current_scene
	check("jogar abre seis fases nomeadas",ui_scene.name=="PhaseSelect" and ui_scene.get_node("Design/Phase1").text.contains("Finn") and ui_scene.get_node("Design/Phase6").text.contains("Três duplas"))
	for size in [Vector2i(800,450),Vector2i(1024,768),Vector2i(1280,720),Vector2i(1920,1080)]:
		root.size=size;await frames(6)
		check("seletor enquadrado em %s"%size,fits(ui_scene.get_node("Design")))
		await capture("selector-%dx%d"%[size.x,size.y])
	root.size=viewport_size

## Exercita a leitura opcional dentro da fase, preservação de controles e retorno seguro.
func in_game_cases() -> void:
	if is_instance_valid(ui_scene):ui_scene.queue_free();await frames(4)
	ui_scene=null
	for slot in [1,2]:
		for number in range(1,7):
			await fresh("res://level_%d.tscn"%number,slot,ROLES[number]);await frames(10)
			var screens=level.get_node("GameScreens")
			var actors=get_nodes_in_group("players")
			var positions: Array=[]
			for actor in actors:positions.append(actor.position)
			await key(KEY_F1)
			check("F%d: F1 abre orientações pausando apenas para leitura"%number,screens.help_open and paused and screens.help_view!=null)
			await frames(60)
			check("F%d: leitura conserva posições"%number,actors[0].position==positions[0] and actors[1].position==positions[1])
			if slot==1 and number==1:
				var before_line: int=level.get_node("FriendshipStory").current_line
				await key(KEY_TAB);await key(KEY_ENTER)
				check("Tab e Enter navegam a ajuda sem avançar diálogo da fase",screens.help_view.active_page==1 and level.get_node("FriendshipStory").current_line==before_line)
			screens.help_view.call("select_page",1);await frames(5)
			check("F%d: ajuda identifica P1/P2 e texto cabe"%number,screens.help_view.get("roles").text.contains("P1:") and screens.help_view.get("roles").text.contains("P2:") and slots_fit(screens.help_view))
			if slot==1:await capture("in-game-help-f%d"%number)
			await key(KEY_ESCAPE)
			check("F%d: Esc retorna sem travar a dupla"%number,not paused and not screens.help_open and actors.all(func(a):return not a.movement_locked))
			if number==2:
				await key(KEY_F1);await key(KEY_F2);level=current_scene;await frames(20)
				check("F2 durante ajuda reinicia e preserva papéis",not paused and level.cake.player_id==slot and not level.get_node("GameScreens").help_open)
	await fresh("res://level_3.tscn",1,"lead_player_id")
	level.bmo.position=Vector2(1050,352);await frames(15);await tap(level.bmo,"interact")
	await key(KEY_F1);check("orientações conservam terminal aberto",paused and level.symbol_terminal.panel_open and level.bmo.movement_locked)
	await key(KEY_ESCAPE);check("retorno não confirma símbolo acidentalmente",not paused and level.symbol_terminal.panel_open and level.symbol_terminal.entered.is_empty())
	await key(KEY_ESCAPE);check("terminal continua cancelável após orientações",not level.symbol_terminal.panel_open and not level.bmo.movement_locked)
	await key(KEY_F1)
	Input.action_press(action(level.marceline,"jump"));level.get_node("GameScreens").close_help();await frames(8)
	check("retorno espera soltar tecla de jogo",paused and level.get_node("GameScreens").closing)
	release();await frames(12)
	check("soltar tecla devolve controle sem salto",not paused and level.marceline.is_on_floor())
	for slot in [1,2]:
		for number in [1,2]:
			await fresh("res://level_%d.tscn"%number,slot,ROLES[number])
			var owner: CoopPlayer=level.jake if number==1 else level.cake
			var friend: CoopPlayer=level.finn if number==1 else level.fionna
			if number==1:
				level.tutorial_solved=true;level.bridge.process_mode=Node.PROCESS_MODE_INHERIT
				owner.position=Vector2(600,369.85)
			else:
				owner.position=Vector2(1488,487);friend.position=Vector2(1424,487)
			await frames(16)
			var bridge=level.bridge if number==1 else level.anchor
			Input.action_press(action(owner,"ability"))
			var formed:=await until(func():return bridge._bridge_active if number==1 else bridge._support_active,240)
			check("F%d: preparação formou ponte em piso seguro"%number,formed)
			friend.position=Vector2(672,359) if number==1 else Vector2(1520,450);friend.velocity=Vector2.ZERO;await frames(22)
			await key(KEY_F1);release();await frames(15)
			check("F%d: ajuda conserva ponte com parceiro apoiado"%number,paused and (bridge._bridge_active if number==1 else bridge._support_active))
			await key(KEY_ESCAPE)
			check("F%d: voltar após soltar habilidade mantém apoio necessário"%number,not paused and (bridge._bridge_active if number==1 else bridge._support_active) and bridge.get_dependents().has(friend))

## Confere continuação, repetição e encerramento com preparação isolada dos estados finais.
func result_cases() -> void:
	for slot in [1,2]:
		for number in range(1,6):
			await fresh("res://level_%d.tscn"%number,slot,ROLES[number]);await finish_fixture(number)
			var screens=level.get_node("GameScreens")
			check("F%d: conclusão tem ações claras e texto enquadrado"%number,screens.result!=null and fits(screens.result_design) and slots_fit(screens.result))
			if slot==1:await capture("result-f%d"%number)
			if number==2:
				screens.result_design.get_node("Repeat").pressed.emit();await frames(30);level=current_scene
				check("repetir limpa progresso e preserva dupla",not level.completed and level.cake.player_id==slot and not paused)
				await finish_fixture(number);screens=level.get_node("GameScreens")
			var lead: int=3-slot if number==2 else slot
			var expected: int=3-lead if number+1==2 else lead
			screens.result_design.get_node("Continue").pressed.emit();await until(func():return is_instance_valid(current_scene) and current_scene!=level,600);level=current_scene
			check("F%d continua na fase correta com papéis preservados"%number,level.scene_file_path=="res://level_%d.tscn"%(number+1) and level.get(ROLES[number+1])==expected and not paused)
	await fresh("res://level_4.tscn",1,"lead_player_id");await finish_fixture(4)
	level.get_node("GameScreens").result_design.get_node("Menu").pressed.emit();await frames(20);ui_scene=current_scene;level=null
	check("conclusão também retorna ao menu",ui_scene.scene_file_path==MENU and not paused)
	if is_instance_valid(ui_scene):ui_scene.queue_free();ui_scene=null;await frames(4)
	await fresh("res://level_6.tscn",1,"primary_player_id")
	level._repair(0);level._repair(1);level._repair(2);level.confirmed=true;level._celebrate();await frames(24)
	var ending=level.get_node("Celebration")
	for size in [Vector2i(800,450),Vector2i(1024,768),Vector2i(1280,720),Vector2i(1920,1080)]:
		root.size=size;await frames(8)
		var inside:=true
		for name in ["Phases","Menu"]:
			var button: Button=ending.get_node(name)
			var transform:=button.get_global_transform_with_canvas()
			var bounds:=Rect2(transform*Vector2.ZERO,button.size*ending.scale)
			inside=inside and Rect2(Vector2.ZERO,root.get_visible_rect().size).grow(1).encloses(bounds)
		check("celebração e botões enquadrados em %s"%size,inside and ending.get_node("Finn")!=null and ending.get_node("BMO")!=null)
		await capture("ending-%dx%d"%[size.x,size.y])
	await key(KEY_ENTER);ui_scene=current_scene;level=null
	check("teclado sai da celebração para seleção",ui_scene.name=="PhaseSelect" and not paused)

## Executa os fluxos de tela com renderização, sem alegar resolver fases pelas fixtures.
func run() -> void:
	root.size=viewport_size
	await menu_cases();await in_game_cases();await result_cases()
	if is_instance_valid(ui_scene):ui_scene.queue_free();ui_scene=null;await frames(4)
	await finish("Telas e orientações de 05/11")
