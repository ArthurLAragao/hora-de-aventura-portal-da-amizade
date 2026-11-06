extends Node2D
## Presentation local to phases 1/6. The main menu, shared HUD and other scenes keep their profile.
const B=preload("res://scripts/core/journey_build.gd")
var level: Node2D
var hint: Label
var help: PanelContainer
var help_text: Label
var previous_size: Vector2i
var previous_mode: int
var previous_aspect: int
var shown_help:=false
var fade: ColorRect
var role_time:=4.0
var previous_roles:=""
## Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: ajuda opcional e apresentação contextual das jornadas.
func _ready() -> void:
	level=get_parent()
	var window=get_window()
	previous_size=window.content_scale_size
	previous_mode=window.content_scale_mode
	previous_aspect=window.content_scale_aspect
	window.content_scale_size=Vector2i(1152,648)
	window.content_scale_mode=Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	window.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_KEEP
	if level.has_node("LogTarget"):level.get_node("LogTarget").hide()
	for node in level.get_children():
		if node is Label: node.hide()
	hint=B.label(self,"",Vector2.ZERO,14,"Context")
	var canvas:=CanvasLayer.new()
	canvas.layer=20
	add_child(canvas)
	help=PanelContainer.new()
	help.position=Vector2(280,180)
	help.custom_minimum_size=Vector2(592,220)
	var style:=StyleBoxFlat.new()
	style.bg_color=Color("102832")
	style.border_color=Color("95d6ba")
	style.set_border_width_all(2)
	style.set_content_margin_all(20)
	help.add_theme_stylebox_override("panel",style)
	fade=ColorRect.new()
	fade.size=Vector2(1152,648)
	fade.color=Color(0.02,0.05,0.08,0)
	fade.mouse_filter=Control.MOUSE_FILTER_IGNORE
	canvas.add_child(fade)
	canvas.add_child(help)
	help_text=B.label(help,"",Vector2.ZERO,17)
	help.hide()
## Trata comandos contextuais de teclado não consumidos pela interface. Contexto: ajuda opcional e apresentação contextual das jornadas.
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode==KEY_F1:
			shown_help=not shown_help
			help.visible=shown_help
		elif event.keycode==KEY_ESCAPE and shown_help:
			shown_help=false
			help.hide()
## Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: ajuda opcional e apresentação contextual das jornadas.
func _process(_delta: float) -> void:
	hint.text=""
	if not is_instance_valid(level): return
	if shown_help:
		var actors=level.get_tree().get_nodes_in_group("players")
		var text:="CONTROLES\n"
		for slot in [1,2]:
			for actor in actors:
				if actor.player_id==slot: text+="P%d — %s\n%s\n"%[slot,String(actor.name),B.controls(actor).replace(" Q","").replace(" Shift direito","") if actor.character_id in [&"bmo",&"fionna"] else B.controls(actor)]
		text+="Finn/Fionna: empurre caminhando.\nF2: reiniciar • R/Backspace: repor objeto próximo\nF1 ou Esc: fechar esta ajuda"
		help_text.text=text
	var roles: String=level.hud.get_node("Hints").text
	if roles!=previous_roles: previous_roles=roles;role_time=3.0
	role_time=maxf(0,role_time-_delta)
	level.hud.get_node("Hints").visible=role_time>0 and not shown_help
	if level.get("completion_count")>0: return
	if level.has_node("TutorialLog"):
		var block=level.tutorial_log if not level.tutorial_solved else level.log
		var actor=level.finn
		if not block.settled and not level.relay_solved and actor.global_position.distance_to(block.global_position)<100 and actor.is_on_floor():
			hint.position=block.position+Vector2(-72,-82 if not level.tutorial_solved else 50)
			hint.text=""
			if absf(block.position.x-(304 if not level.tutorial_solved else 1360))>80: hint.text=("R" if actor.player_id==1 else "Backspace")+": repor"
		for gate in [level.tutorial_gate,level.relay_gate,level.final_gate]:
			gate.get_node("Sprite2D").visible=not gate.is_open
	else:
		if level.stage==1:
			var cake=level.pair[1]
			var prompt=level.tunnel.get_node("Prompt")
			prompt.text=("E" if cake.player_id==1 else "Enter")+": rastejar" if level.tunnel.call("can_interact",cake) and not cake.crawling else ""
			if cake.crawling: prompt.text="Esquerda/direita: rastejar"
			if level.mechanism_unlocked: level.crank.get_node("Status").text=""
		elif level.stage==2:
			level.music.get_node("Status").text=""
			level.terminal.get_node("Status").text=""
			if level.clue_revealed and not level.repaired[2]: level.terminal.get_node("Prompt").text=("E" if level.pair[1].player_id==1 else "Enter")+": conectar" if level.terminal.call("can_interact",level.pair[1]) else ""
## Limpa referências/estado temporário ao retirar o componente da árvore. Contexto: ajuda opcional e apresentação contextual das jornadas.
func _exit_tree() -> void:
	var window=get_window()
	if is_instance_valid(window):
		window.content_scale_size=previous_size
		window.content_scale_mode=previous_mode
		window.content_scale_aspect=previous_aspect

## Executa o escurecimento breve da transição e aguarda o tween terminar.
func fade_out() -> void:
	var tween=create_tween()
	tween.tween_property(fade,"color:a",0.85,0.16)
	await tween.finished
## Restaura gradualmente a visão após a transição.
func fade_in() -> void:
	var tween=create_tween()
	tween.tween_property(fade,"color:a",0.0,0.20)
	await tween.finished
