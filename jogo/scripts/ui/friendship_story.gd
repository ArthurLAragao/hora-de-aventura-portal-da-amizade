extends Node
## Conversas de abertura: controles só voltam após ler ou pular e soltar as teclas.
const SCRIPT=preload("res://scripts/content/friendship_lines.gd")
const UI=preload("res://scripts/ui/menu_layout.gd")
const FONT=preload("res://Assets/08_Fonts/PixelifySans.ttf")
const NAMES={"finn":"Finn","jake":"Jake","fionna":"Fionna","cake":"Cake","marceline":"Marceline","bmo":"BMO"}
@export_range(1,6) var phase:=1
@export var enabled:=true
var level: Node2D
var canvas: CanvasLayer
var card: PanelContainer
var shade: ColorRect
var portrait: TextureRect
var partner_portrait: TextureRect
var speaker: Label
var partner_name: Label
var dialogue: Label
var footer: Label
var next_button: Button
var skip_button: Button
var modal_active:=false
var previous_paused:=false
var closing:=false
var armed:=false
var arm_time:=0.0
var ready_to_watch:=false
var seen: Dictionary={}
var emitted: Array[String]=[]
var current_lines: Array=[]
var last_lines: Array=[]
var current_id:=""
var current_line:=0
var stage_seen:=0
var portraits: Dictionary={}
var last_viewport:=Vector2.ZERO

## A apresentação continua processando durante sua própria pausa; o mundo não.
func _ready() -> void:
	process_mode=Node.PROCESS_MODE_ALWAYS;level=get_parent()
	canvas=CanvasLayer.new();canvas.name="Conversation";canvas.layer=42;add_child(canvas)
	shade=ColorRect.new();shade.color=Color(0.02,0.06,0.10,0.22);shade.mouse_filter=Control.MOUSE_FILTER_STOP;canvas.add_child(shade)
	card=PanelContainer.new();card.name="Card";card.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;canvas.add_child(card)
	var style:=preload("res://scripts/ui/sprite_art.gd").skin(true)
	style.set_content_margin(SIDE_LEFT,30);style.set_content_margin(SIDE_RIGHT,30);style.set_content_margin(SIDE_TOP,24);style.set_content_margin(SIDE_BOTTOM,18)
	card.add_theme_stylebox_override("panel",style)
	var stack:=VBoxContainer.new();stack.add_theme_constant_override("separation",12);card.add_child(stack)
	var row:=HBoxContainer.new();row.add_theme_constant_override("separation",22);stack.add_child(row)
	var left:=VBoxContainer.new();left.custom_minimum_size.x=112;row.add_child(left)
	portrait=portrait_box(left);speaker=make_label(20);speaker.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;left.add_child(speaker)
	dialogue=make_label(24);dialogue.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;dialogue.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;dialogue.size_flags_horizontal=Control.SIZE_EXPAND_FILL;dialogue.custom_minimum_size=Vector2(150,104);row.add_child(dialogue)
	var right:=VBoxContainer.new();right.custom_minimum_size.x=112;row.add_child(right)
	partner_portrait=portrait_box(right);partner_name=make_label(20);partner_name.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;right.add_child(partner_name)
	var controls:=HBoxContainer.new();controls.alignment=BoxContainer.ALIGNMENT_CENTER;controls.add_theme_constant_override("separation",16);stack.add_child(controls)
	footer=make_label(16);footer.size_flags_vertical=Control.SIZE_SHRINK_CENTER;controls.add_child(footer)
	next_button=Button.new();next_button.text="Próxima";next_button.custom_minimum_size=Vector2(132,34);next_button.add_theme_font_override("font",FONT);next_button.add_theme_font_size_override("font_size",20);preload("res://scripts/ui/sprite_art.gd").button(next_button);controls.add_child(next_button);next_button.pressed.connect(advance)
	skip_button=Button.new();skip_button.text="Pular";skip_button.custom_minimum_size=Vector2(108,34);skip_button.add_theme_font_override("font",FONT);skip_button.add_theme_font_size_override("font_size",20);preload("res://scripts/ui/sprite_art.gd").button(skip_button);controls.add_child(skip_button);skip_button.pressed.connect(skip)
	canvas.hide();get_viewport().size_changed.connect(layout_card.bind(true));start.call_deferred()

## Retrato recortado pela região opaca uma vez, centralizado dentro da moldura.
func portrait_box(parent: Node) -> TextureRect:
	var frame:=PanelContainer.new();frame.add_theme_stylebox_override("panel",preload("res://scripts/ui/sprite_art.gd").skin());parent.add_child(frame)
	var picture:=TextureRect.new();picture.custom_minimum_size=Vector2(84,84);picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;picture.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;picture.mouse_filter=Control.MOUSE_FILTER_IGNORE;frame.add_child(picture);return picture
func make_label(size: int) -> Label:
	var text:=Label.new();text.add_theme_font_override("font",FONT);text.add_theme_font_size_override("font_size",size);text.mouse_filter=Control.MOUSE_FILTER_IGNORE;return text
func trimmed(id: String) -> Texture2D:
	if not portraits.has(id):
		var source: Texture2D=load("res://Assets/01_Characters/%s/portrait.png"%id)
		var atlas:=AtlasTexture.new();atlas.atlas=source;atlas.region=source.get_image().get_used_rect();portraits[id]=atlas
	return portraits[id]
func role_name(id: String) -> String:
	for actor in get_tree().get_nodes_in_group("players"):
		if String(actor.character_id)==id and actor.is_visible_in_tree():return NAMES[id]+" · P%d"%actor.player_id
	return NAMES.get(id,id)
func start() -> void:
	ready_to_watch=true
	if not enabled:return
	var startup: Array=[]
	for actor in get_tree().get_nodes_in_group("players"):
		startup.append([actor,actor.movement_locked]);actor.movement_locked=true
	await get_tree().physics_frame
	await get_tree().physics_frame
	if not is_inside_tree():return
	if level.has_method("ground_initial_pair"):level.ground_initial_pair()
	await get_tree().physics_frame
	await get_tree().physics_frame
	if not is_inside_tree():return
	for entry in startup:
		if is_instance_valid(entry[0]):entry[0].movement_locked=entry[1]
	queue_moment("intro")

## API observada pela HUD: os estados vêm dos mecanismos reais, sem conceder progresso.
func snapshot() -> Dictionary:
	match phase:
		1:return {"first":level.tutorial_solved,"passage":level.permanent.visible,"cooperation":level.relay_solved,"crystal":level.crystal_count>0,"ending":level.completion_count>0,"recovery":level.fall.recovery_count}
		2:return {"first":level.first_unlocked,"passage":level.first_crank.solved,"cooperation":level.crank.solved and level.get_node("ExtendPlatform").extended,"crystal":level.crystal_collected,"ending":level.completed,"recovery":level.recovery_count}
		3:return {"first":level.get_node("MusicGate").is_open,"passage":level.symbol_terminal.solved,"cooperation":level.get_node("RegionalLayout").confirmation_solved,"crystal":level.get_node("CooperativeExit")._crystal_collected,"ending":level.completion_count>0,"recovery":level.get_node("FallZone").recovery_count}
		4:return {"first":level.carrier.arrived,"passage":level.get_node("TrunkPuzzle/Gate").is_open,"cooperation":level.energy_terminal.energized,"crystal":level.get_node("CooperativeExit")._crystal_collected,"ending":level.completion_count>0,"recovery":level.get_node("FallZone").recovery_count}
		5:return {"first":level.solved[0],"passage":level.solved[1],"cooperation":level.solved[2],"crystal":level.exit_area._crystal_collected,"ending":level.completion_count>0,"recovery":level.recovery_count}
		6:return {"first":level.repaired[0],"passage":level.clue_revealed,"cooperation":level.repaired[2],"crystal":level.crystal_count>0,"ending":level.completion_count>0,"recovery":level.recovery_count}
	return {}

## Somente abertura/trocas de dupla iniciam conversas; conquistas não geram caixas avulsas.
func queue_moment(id: String,_replace:=false) -> void:
	if seen.has(id) or not (id=="intro" or id.begins_with("pair")):return
	seen[id]=true;emitted.append(id)
	var lines: Array=SCRIPT.LINES[phase].get(id,[])
	if not lines.is_empty():begin(lines,id)
func begin(lines: Array,id: String) -> void:
	if not modal_active:previous_paused=get_tree().paused
	current_lines=lines.duplicate(true);last_lines=current_lines.duplicate(true);current_id=id;current_line=0;closing=false;modal_active=true
	get_tree().paused=true;level.set_meta("dialogue_modal",true);canvas.show();show_line()
func show_line() -> void:
	var line: Array=current_lines[current_line];var id:=String(line[0]);portrait.texture=trimmed(id);speaker.text=role_name(id)
	for actor in get_tree().get_nodes_in_group("players"):
		if String(actor.character_id)!=id and actor.is_visible_in_tree():partner_portrait.texture=trimmed(String(actor.character_id));partner_name.text=role_name(String(actor.character_id));break
	dialogue.text=line[1];footer.text="%d/%d · Tab / Enter"%[current_line+1,current_lines.size()]
	next_button.text="Jogar" if current_line==current_lines.size()-1 else "Próxima"
	armed=false;arm_time=0;next_button.disabled=true;skip_button.disabled=true;layout_card(true)
func layout_card(_force:=false) -> void:
	if not is_inside_tree() or is_queued_for_deletion() or not is_instance_valid(card) or get_viewport()==null:return
	var size:=get_viewport().get_visible_rect().size;shade.size=size;card.size=Vector2(minf(1008,size.x-48),0)
	card.position=Vector2((size.x-card.size.x)*0.5,maxf(20,size.y-card.size.y-24));settle_height.call_deferred()
func settle_height() -> void:
	if not is_inside_tree():return
	await get_tree().process_frame
	if is_inside_tree():card.size.y=0;card.position.y=maxf(20,get_viewport().get_visible_rect().size.y-card.size.y-24)
func advance() -> void:
	if not modal_active or not armed or closing:return
	current_line+=1
	if current_line>=current_lines.size():skip()
	else:show_line()
func skip() -> void:
	if not modal_active or not armed:return
	closing=true;next_button.disabled=true;skip_button.disabled=true;footer.text="Solte as teclas para jogar"

## Sempre restaura a pausa anterior, inclusive ao reiniciar ou sair da cena.
func clear_card() -> void:
	if modal_active and get_tree()!=null:get_tree().paused=previous_paused
	modal_active=false;closing=false;current_lines.clear();current_id="";canvas.hide();level.set_meta("dialogue_modal",false)
func obstructed() -> bool:
	var screens=level.get_node_or_null("GameScreens")
	if screens!=null and (screens.help_open or screens.leaving):return true
	if phase==6 and (level._transitioning or level._recovering):return true
	return false
func _process(delta: float) -> void:
	if not ready_to_watch:return
	if modal_active:
		arm_time+=delta
		if closing:
			if not UI.game_input_held():clear_card()
		elif arm_time>0.18 and not UI.game_input_held():armed=true;next_button.disabled=false;skip_button.disabled=false
		return
	if enabled and phase==6 and not obstructed() and stage_seen!=level.stage:
		stage_seen=level.stage;queue_moment("pair%d"%stage_seen)
func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:return
	if modal_active:
		get_viewport().set_input_as_handled()
		if event.keycode==KEY_F2:
			clear_card();level.get_node("GameScreens").restart_phase()
		elif armed and event.keycode==KEY_ESCAPE:skip()
		elif armed and event.keycode in [KEY_TAB,KEY_ENTER,KEY_KP_ENTER,KEY_SPACE,KEY_E]:advance()
	elif enabled and event.keycode==KEY_F3 and not last_lines.is_empty() and not obstructed():
		begin(last_lines,"replay");get_viewport().set_input_as_handled()
func _exit_tree() -> void:
	if modal_active and get_tree()!=null:get_tree().paused=previous_paused
