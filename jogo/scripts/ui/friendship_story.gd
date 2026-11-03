extends Node
## Miniconversas reativas: apresentação separada da física, das entradas e da progressão.
const SCRIPT=preload("res://scripts/content/friendship_lines.gd")
const FONT=preload("res://Assets/08_Fonts/NotoSans.ttf")
const NAMES={"finn":"Finn","jake":"Jake","fionna":"Fionna","cake":"Cake","marceline":"Marceline","bmo":"BMO"}
@export_range(1,6) var phase:=1
@export_range(3.0,12.0,0.5) var minimum_read_seconds:=7.0
@export var enabled:=true
var level: Node2D
var canvas: CanvasLayer
var card: PanelContainer
var portrait: TextureRect
var speaker: Label
var dialogue: Label
var footer: Label
var seen: Dictionary={}
var emitted: Array[String]=[]
var pending: Array[Dictionary]=[]
var current_lines: Array=[]
var current_id:=""
var current_line:=0
var last_lines: Array=[]
var remaining:=0.0
var poll_left:=0.0
var stage_seen:=0
var recoveries:=0
var ready_to_watch:=false
var tween: Tween
var last_viewport:=Vector2.ZERO
var portraits: Dictionary={}

## Constrói o cartão e aguarda a montagem da fase antes de consultar seus eventos.
func _ready() -> void:
	level=get_parent()
	canvas=CanvasLayer.new();canvas.name="Conversation";canvas.layer=15;add_child(canvas)
	card=PanelContainer.new();card.name="Card";card.mouse_filter=Control.MOUSE_FILTER_IGNORE;canvas.add_child(card)
	var style:=StyleBoxFlat.new();style.bg_color=Color("102832f2");style.border_color=Color("d6cf9a")
	style.set_border_width_all(2);style.set_corner_radius_all(6);style.set_content_margin_all(12)
	card.add_theme_stylebox_override("panel",style)
	var row:=HBoxContainer.new();row.mouse_filter=Control.MOUSE_FILTER_IGNORE;row.add_theme_constant_override("separation",12);card.add_child(row)
	portrait=TextureRect.new();portrait.custom_minimum_size=Vector2(54,64);portrait.size_flags_vertical=Control.SIZE_SHRINK_CENTER;portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;portrait.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;portrait.mouse_filter=Control.MOUSE_FILTER_IGNORE;row.add_child(portrait)
	var column:=VBoxContainer.new();column.size_flags_horizontal=Control.SIZE_EXPAND_FILL;column.mouse_filter=Control.MOUSE_FILTER_IGNORE;row.add_child(column)
	speaker=make_label(16);column.add_child(speaker)
	dialogue=make_label(18);dialogue.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;dialogue.custom_minimum_size=Vector2(0,52);column.add_child(dialogue)
	footer=make_label(11);footer.modulate=Color("c2c8c5");column.add_child(footer);footer.hide()
	card.hide()
	start.call_deferred()

## Cria rótulos sem foco nem captura de cliques ou teclas dos jogadores.
func make_label(size: int) -> Label:
	var label:=Label.new();label.add_theme_font_override("font",FONT);label.add_theme_font_size_override("font_size",size);label.mouse_filter=Control.MOUSE_FILTER_IGNORE
	return label

## Abre o contexto da fase sem simular cristais anteriores nem conceder progresso.
func start() -> void:
	ready_to_watch=true
	if not enabled:return
	queue_moment("intro")

## Consulta somente estados conquistados no jogo, com frequência reduzida.
func snapshot() -> Dictionary:
	match phase:
		1:return {"first":level.tutorial_solved,"passage":level.permanent.visible,"cooperation":level.relay_solved,"crystal":level.crystal_count>0,"ending":level.completion_count>0,"recovery":level.fall.recovery_count}
		2:return {"first":level.first_unlocked,"passage":level.first_crank.solved,"cooperation":level.crank.solved and level.get_node("ExtendPlatform").extended,"crystal":level.crystal_collected,"ending":level.completed,"recovery":level.recovery_count}
		3:return {"first":level.get_node("MusicGate").is_open,"passage":level.symbol_terminal.solved,"cooperation":level.get_node("RegionalLayout").confirmation_solved,"crystal":level.get_node("FriendshipCrystal").is_collected,"ending":level.completion_count>0,"recovery":level.get_node("FallZone").recovery_count}
		4:return {"first":level.carrier.arrived,"passage":level.get_node("TrunkPuzzle/Gate").is_open,"cooperation":level.energy_terminal.energized,"crystal":level.get_node("FriendshipCrystal").is_collected,"ending":level.completion_count>0,"recovery":level.get_node("FallZone").recovery_count}
		5:return {"first":level.solved[0],"passage":level.solved[1],"cooperation":level.solved[2],"crystal":level.crystal.is_collected,"ending":level.completion_count>0,"recovery":level.recovery_count}
		6:return {"first":level.repaired[0],"passage":level.clue_revealed,"cooperation":level.repaired[2],"crystal":level.crystal_count>0,"ending":level.completion_count>0,"recovery":level.recovery_count}
	return {}

## Enfileira um acontecimento uma vez; conclusões substituem comentários atrasados.
func queue_moment(id: String,replace_current:=false) -> void:
	if seen.has(id):return
	seen[id]=true;emitted.append(id)
	var lines: Array=SCRIPT.LINES[phase].get(id,[])
	if id in ["first","passage","cooperation","crystal"] and current_id=="intro":replace_current=true
	if replace_current:clear_card()
	if lines.is_empty():return
	pending.append({"id":id,"lines":lines.duplicate(true)})
	# Evita acumular um tutorial quando a dupla avança rapidamente.
	if pending.size()>2:pending.remove_at(0)
	if current_lines.is_empty():next_sequence()

## Inicia a próxima conversa e conserva somente a última para a releitura opcional.
func next_sequence() -> void:
	if pending.is_empty():
		current_lines.clear();current_id="";card.hide();return
	var moment: Dictionary=pending.pop_front();current_id=moment.id;current_lines=moment.lines;last_lines=current_lines.duplicate(true);current_line=0
	show_line()

## Mostra retrato original, nome, papel atual e uma fala completa, sem efeito de digitação.
func show_line() -> void:
	var line: Array=current_lines[current_line]
	if not portraits.has(line[0]):portraits[line[0]]=load("res://Assets/01_Characters/%s/portrait.png"%line[0])
	portrait.texture=portraits[line[0]]
	var role:=""
	for actor in get_tree().get_nodes_in_group("players"):
		if String(actor.character_id)==line[0]:role=" · P%d"%actor.player_id;break
	speaker.text=NAMES[line[0]]+role
	dialogue.text=line[1]
	footer.text="%d/%d · Tab: próxima · F3: rever"%[current_line+1,current_lines.size()]
	remaining=maxf(minimum_read_seconds,String(line[1]).length()*0.075)
	card.modulate.a=0.0;card.show();layout_card(true)
	if tween:tween.kill()
	tween=create_tween();tween.tween_property(card,"modulate:a",1.0,0.15)

## Posiciona o cartão fora da faixa principal do chão, respeitando a tela atual.
func layout_card(force:=false) -> void:
	var viewport:=get_viewport().get_visible_rect().size
	if viewport==last_viewport and not force:return
	last_viewport=viewport
	var width:=minf(400.0,viewport.x-32)
	card.size=Vector2(width,0);card.position=Vector2(viewport.x-width-16,112)
	settle_height.call_deferred()

## Espera a largura dos contêineres estabilizar antes de reduzir a altura do texto quebrado.
func settle_height() -> void:
	await get_tree().process_frame
	card.size=Vector2(card.size.x,0)

## Avança ou encerra a fala sem consumir interação, salto ou habilidade dos jogadores.
func advance() -> void:
	if current_lines.is_empty():return
	current_line+=1
	if current_line>=current_lines.size():next_sequence()
	else:show_line()

## Limpa fila e cartão ao recuperar, trocar de dupla ou priorizar um novo contexto.
func clear_card() -> void:
	pending.clear();current_lines.clear();current_id="";remaining=0.0;card.hide()

## Identifica painéis e transições que precisam de toda a atenção visual.
func obstructed() -> bool:
	if phase==6 and (level._transitioning or level._recovering):return true
	if phase in [3,4]:
		var hud=level.get_node("HUD")
		if hud.help_panel.visible:return true
		if level.bmo.interaction_owner!=null and is_instance_valid(level.bmo.interaction_owner) and level.bmo.interaction_owner.get("panel_open")==true:return true
	if phase==6 and level.terminal.get("panel_open"):return true
	if phase in [1,6] and level.has_node("QualityPresentation") and level.get_node("QualityPresentation").shown_help:return true
	if phase==5 and level.get_node("HUD/Help").visible:return true
	if phase==2:
		for child in level.get_node("Instructions").get_children():
			if child is PanelContainer and child.visible:return true
	return false

## Reage a conquistas e erros sem escrever em estados dos puzzles ou dos personagens.
func _process(delta: float) -> void:
	if not ready_to_watch:return
	if not enabled:card.hide();return
	# A troca existente cuida dos atores; a nova dupla só fala depois de receber controles.
	if phase==6 and (level._transitioning or level._recovering):
		clear_card();canvas.hide();return
	poll_left-=delta
	if poll_left<=0:
		poll_left=0.15
		var state:=snapshot()
		if not state.ending and int(state.recovery)>recoveries:
			recoveries=state.recovery;clear_card()
			if not seen.has("retry"):
				seen["retry"]=true;emitted.append("retry")
				var actor=get_tree().get_nodes_in_group("players")[0]
				pending.append({"id":"retry","lines":[[String(actor.character_id),"Tudo bem. Vamos tentar de novo em dupla!"]]});next_sequence()
		if phase==6 and stage_seen!=level.stage:
			stage_seen=level.stage
			queue_moment("pair%d"%stage_seen,true)
		if state.ending:
			queue_moment("ending",true)
			if phase==6:clear_card();return
		else:
			for id in ["first","passage","cooperation","crystal"]:
				if state[id]:queue_moment(id)
	if obstructed():
		if not current_lines.is_empty():clear_card()
		canvas.hide();return
	canvas.show()
	if not current_lines.is_empty():
		layout_card();remaining-=delta
		if remaining<=0:advance()

## Tab avança texto; F3 relê a conversa mais recente. As teclas de jogo não são capturadas.
func _input(event: InputEvent) -> void:
	if not enabled or not ready_to_watch or obstructed():return
	if phase==6 and level.completion_count>0:return
	if not event is InputEventKey or not event.pressed or event.echo:return
	if event.keycode==KEY_TAB and not current_lines.is_empty():
		advance();get_viewport().set_input_as_handled()
	elif event.keycode==KEY_F3 and not last_lines.is_empty():
		clear_card();pending.append({"id":"replay","lines":last_lines.duplicate(true)});next_sequence();get_viewport().set_input_as_handled()
