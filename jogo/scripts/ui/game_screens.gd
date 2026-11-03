extends Node
## Liga orientações e conclusão à fase atual sem mudar puzzles, personagens ou seus controles.
const UI=preload("res://scripts/ui/menu_layout.gd")
const GUIDE=preload("res://scripts/ui/instructions_screen.gd")
const B=preload("res://scripts/core/journey_build.gd")
const ROLE_KEYS={1:"finn_player_id",2:"cake_player_id",3:"lead_player_id",4:"lead_player_id",5:"lead_player_id",6:"primary_player_id"}
const PHASES=["Trilha da Casa na Árvore","Passagem do Reino Gelado","Caverna Musical","Oficina do Reino Doce","Torre dos Espelhos","Portal da Amizade"]
@export_range(1,6) var phase:=1
var level: Node2D
var layer: CanvasLayer
var help_view: Control
var result: Control
var result_design: Control
var help_open:=false
var closing:=false
var leaving:=false
var previous_paused:=false
var story_was_visible:=false
var poll_left:=0.0

## Mantém somente as telas processando durante a leitura opcional pausada.
func _ready() -> void:
	process_mode=Node.PROCESS_MODE_ALWAYS;level=get_parent()
	layer=CanvasLayer.new();layer.name="ScreenLayer";layer.layer=40;add_child(layer)
	connect_help_buttons.call_deferred()
	get_viewport().size_changed.connect(fit_result)

## Substitui apenas os vínculos dos botões de ajuda já existentes.
func connect_help_buttons() -> void:
	for container_name in ["HUD","Instructions"]:
		var container=level.get_node_or_null(container_name)
		if container==null:continue
		for child in container.get_children():
			if child is Button and child.text=="Controles":
				for connection in child.pressed.get_connections():child.pressed.disconnect(connection.callable)
				child.pressed.connect(open_help)

## Consulta a conclusão conquistada pela lógica original da fase.
func completed() -> bool:
	return level.completed if phase==2 else level.completion_count>0

## Abre as orientações sobre a fase, conservando posições, painéis e interações em andamento.
func open_help() -> void:
	if help_open or completed():return
	if phase==6 and (level._transitioning or level._recovering):return
	if phase==5 and level.recovering:return
	var fall=level.get_node_or_null("FallZone")
	if fall!=null and fall.get("_respawning")==true:return
	previous_paused=get_tree().paused;help_open=true
	var legacy=level.get_node_or_null("QualityPresentation")
	if legacy!=null:legacy.shown_help=false;legacy.help.hide()
	for name in ["HUD","Instructions"]:
		var old=level.get_node_or_null(name)
		if old==null:continue
		for child in old.get_children():
			if child is PanelContainer or child.name==&"Help":child.hide()
	var story=level.get_node_or_null("FriendshipStory")
	if story!=null:story_was_visible=story.canvas.visible;story.canvas.hide()
	help_view=GUIDE.new();help_view.name="Orientations";help_view.set("embedded",true);layer.add_child(help_view)
	var roles: Array[String]=[]
	for slot in [1,2]:
		for actor in get_tree().get_nodes_in_group("players"):
			if actor.player_id==slot:roles.append("P%d: %s"%[slot,String(actor.character_id).capitalize() if actor.character_id!=&"bmo" else "BMO"])
	help_view.call("set_roles","Agora: "+" · ".join(roles))
	help_view.connect("close_requested",close_help)
	get_tree().paused=true

## Espera a liberação das entradas para evitar salto ou confirmação acidental ao voltar.
func close_help() -> void:
	if not help_open or closing:return
	closing=true
	var back=help_view.get("back") as Button;back.disabled=true
	if UI.game_input_held():back.text="Soltem as teclas para voltar"
	while UI.game_input_held():
		if not is_inside_tree() or not help_open:return
		await get_tree().process_frame
	await get_tree().process_frame
	if is_inside_tree() and help_open:restore_help()

## Restaura exatamente a pausa e a conversa que existiam antes das orientações.
func restore_help() -> void:
	if is_instance_valid(help_view):help_view.queue_free()
	help_view=null;help_open=false;closing=false;get_tree().paused=previous_paused
	var story=level.get_node_or_null("FriendshipStory")
	if story!=null:story.canvas.visible=story_was_visible

## Reinicia pelo padrão da fase, preservando papéis e encerrando a leitura opcional.
func restart_phase() -> void:
	if help_open:restore_help()
	B.restart(level,ROLE_KEYS[phase])

## Cria a conclusão das Fases 1–5; a Fase 6 conserva sua celebração própria.
func show_result() -> void:
	if result!=null or phase==6:return
	hide_legacy_buttons(level)
	result=Control.new();result.name="Result";layer.add_child(result);result.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	result_design=Control.new();result_design.name="Design";result_design.size=Vector2(1152,648);result.add_child(result_design)
	UI.panel(result_design,Rect2(136,468,880,166))
	var title:=UI.label(result_design,"Cristal recuperado em dupla!",Rect2(156,478,840,36),26);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	var subtitle:=UI.label(result_design,PHASES[phase-1],Rect2(156,518,840,28),18);subtitle.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	var next:=UI.button(result_design,"Próxima fase",Rect2(156,564,210,48),"Continue")
	var repeat:=UI.button(result_design,"Repetir",Rect2(376,564,180,48),"Repeat")
	var phases:=UI.button(result_design,"Fases",Rect2(566,564,210,48),"Phases")
	var menu:=UI.button(result_design,"Menu",Rect2(786,564,210,48),"Menu")
	next.pressed.connect(continue_phase);repeat.pressed.connect(restart_phase)
	phases.pressed.connect(navigate.bind("res://phase_select.tscn",0));menu.pressed.connect(navigate.bind("res://Assets/04_Interface/Godot/main_menu.tscn",0))
	fit_result();arm_result.call_deferred(next)

## Retira os botões anteriores de conclusão sem apagar nós ou callbacks existentes.
func hide_legacy_buttons(parent: Node) -> void:
	if parent==self:return
	for child in parent.get_children():
		if child is Button:child.hide()
		hide_legacy_buttons(child)

## Libera foco da conclusão depois que as entradas de jogo forem soltas.
func arm_result(first: Button) -> void:
	for child in result_design.get_children():
		if child is Button:child.disabled=true
	while UI.game_input_held():
		if not is_inside_tree() or not is_instance_valid(result_design):return
		await get_tree().process_frame
	for child in result_design.get_children():
		if child is Button:child.disabled=false
	first.grab_focus()

## Continua por escolha explícita, mantendo os lugares de P1/P2 na dupla seguinte.
func continue_phase() -> void:
	if phase>=6:return
	var lead: int=level.get(ROLE_KEYS[phase])
	if phase==2:lead=3-lead
	var next_role:=3-lead if phase+1==2 else lead
	navigate("res://level_%d.tscn"%(phase+1),next_role)

## Troca de tela após liberar entradas; apenas o papel é transferido, não progresso inventado.
func navigate(path: String,role: int) -> void:
	if leaving:return
	leaving=true
	while UI.game_input_held():
		if not is_inside_tree():return
		await get_tree().process_frame
	if not is_inside_tree():return
	if role>0:get_tree().set_meta("journey_restart",{"scene":path,"role":role})
	var error:=get_tree().change_scene_to_file(path)
	if error!=OK:leaving=false;push_error("Não foi possível abrir a tela: "+path)

## Mantém a conclusão ajustada à área virtual disponível, sem alterar a câmera.
func fit_result() -> void:
	if is_inside_tree() and get_viewport()!=null and is_instance_valid(result_design):UI.fit(result_design,get_viewport().get_visible_rect().size,Vector2(1152,648))

## Observa somente a conquista final; os puzzles continuam sendo processados pelos scripts originais.
func _process(delta: float) -> void:
	poll_left-=delta
	if poll_left>0:return
	poll_left=0.1
	if completed():show_result()

## F1 abre orientações e Esc retorna à fase; F2 reinicia com segurança mesmo durante a leitura.
func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:return
	if help_open:
		if event.keycode==KEY_F1 or event.keycode==KEY_ESCAPE:close_help();get_viewport().set_input_as_handled()
		elif event.keycode==KEY_F2:get_viewport().set_input_as_handled();restart_phase()
	elif event.keycode==KEY_F1:
		if not completed():open_help()
		get_viewport().set_input_as_handled()

## Garante que sair de uma cena durante a leitura não deixe o menu pausado.
func _exit_tree() -> void:
	if help_open and get_tree()!=null:get_tree().paused=previous_paused
