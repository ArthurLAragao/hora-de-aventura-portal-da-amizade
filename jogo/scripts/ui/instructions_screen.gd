extends Control
## Teclado completo interativo. A demonstração não injeta ações no jogo pausado.
signal close_requested
const UI=preload("res://scripts/ui/menu_layout.gd")
const REFERENCE=Vector2(1280,720)
const MAIN="res://Assets/04_Interface/Godot/main_menu.tscn"
@export var embedded:=false
var design: Control
var back: Button
var roles: Label
var keys: Dictionary={}
var active: Dictionary={}
var held: Dictionary={}
var demos: Array[AnimatedSprite2D]=[]
var demo_time: Array[float]=[0.0,0.0]
var demo_action: Array[String]=["",""]
var action_labels: Array[Label]=[]
var elapsed:=0.0
var key_count:=0
var demo_bases: Array[Vector2]=[]

func _ready() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT);texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	var backdrop:=ColorRect.new();backdrop.color=Color("0d2530");backdrop.set_anchors_and_offsets_preset(PRESET_FULL_RECT);add_child(backdrop)
	design=Control.new();design.name="Design";design.size=REFERENCE;add_child(design)
	var art:=TextureRect.new();art.texture=load("res://Assets/06_Story_Screens/discovery.png");art.size=REFERENCE
	art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED;art.modulate=Color("657e77");art.mouse_filter=MOUSE_FILTER_IGNORE;design.add_child(art)
	UI.label(design,"EXPERIMENTE AS TECLAS",Rect2(56,24,1168,48),32)
	UI.label(design,"Aperte no teclado ou clique em uma tecla.",Rect2(56,78,1168,30),20)
	for i in 2:
		var at:=Vector2(56+i*588,122);UI.panel(design,Rect2(at,Vector2(568,106)))
		UI.label(design,"P%d · %s"%[i+1,"Finn" if i==0 else "Jake"],Rect2(at+Vector2(22,14),Vector2(128,24)),20).modulate=Color("87daba") if i==0 else Color("f1ca80")
		var actor:=AnimatedSprite2D.new();actor.sprite_frames=load("res://Assets/01_Characters/"+("finn" if i==0 else "jake")+"/animations.tres")
		var texture:=actor.sprite_frames.get_frame_texture(&"idle",0);var used:=texture.get_image().get_used_rect()
		actor.offset=texture.get_size()*0.5-Vector2(used.get_center());actor.position=at+Vector2(86,70)
		actor.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;design.add_child(actor);actor.play(&"idle");demos.append(actor);demo_bases.append(actor.position)
		action_labels.append(UI.label(design,"Vamos experimentar!",Rect2(at+Vector2(176,22),Vector2(364,30)),24))
		UI.label(design,"Andar   ·   Pular   ·   Usar   ·   Poder",Rect2(at+Vector2(176,62),Vector2(364,26)),18)
	# Bloco principal, funções, navegação e teclado numérico: 104 teclas representadas.
	var rows=[
		[["Esc",KEY_ESCAPE,1],["F1",KEY_F1,1],["F2",KEY_F2,1],["F3",KEY_F3,1],["F4",KEY_F4,1],["F5",KEY_F5,1],["F6",KEY_F6,1],["F7",KEY_F7,1],["F8",KEY_F8,1],["F9",KEY_F9,1],["F10",KEY_F10,1],["F11",KEY_F11,1],["F12",KEY_F12,1]],
		[["`",KEY_QUOTELEFT,1],["1",KEY_1,1],["2",KEY_2,1],["3",KEY_3,1],["4",KEY_4,1],["5",KEY_5,1],["6",KEY_6,1],["7",KEY_7,1],["8",KEY_8,1],["9",KEY_9,1],["0",KEY_0,1],["-",KEY_MINUS,1],["=",KEY_EQUAL,1],["⌫",KEY_BACKSPACE,2]],
		[["Tab",KEY_TAB,1.5],["Q",KEY_Q,1],["W",KEY_W,1],["E",KEY_E,1],["R",KEY_R,1],["T",KEY_T,1],["Y",KEY_Y,1],["U",KEY_U,1],["I",KEY_I,1],["O",KEY_O,1],["P",KEY_P,1],["[",KEY_BRACKETLEFT,1],["]",KEY_BRACKETRIGHT,1],["\\",KEY_BACKSLASH,1.5]],
		[["Caps",KEY_CAPSLOCK,1.75],["A",KEY_A,1],["S",KEY_S,1],["D",KEY_D,1],["F",KEY_F,1],["G",KEY_G,1],["H",KEY_H,1],["J",KEY_J,1],["K",KEY_K,1],["L",KEY_L,1],[";",KEY_SEMICOLON,1],["'",KEY_APOSTROPHE,1],["Enter",KEY_ENTER,2.25]],
		[["Shift",KEY_SHIFT,2.25],["Z",KEY_Z,1],["X",KEY_X,1],["C",KEY_C,1],["V",KEY_V,1],["B",KEY_B,1],["N",KEY_N,1],["M",KEY_M,1],[",",KEY_COMMA,1],[".",KEY_PERIOD,1],["/",KEY_SLASH,1],["Shift dir.",KEY_SHIFT+1000,2.75]],
		[["Ctrl",KEY_CTRL,1.25],["Win",KEY_META,1.25],["Alt",KEY_ALT,1.25],["Espaço",KEY_SPACE,6.25],["Alt",KEY_ALT+1000,1.25],["Win",KEY_META+1000,1.25],["☰",KEY_MENU,1.25],["Ctrl",KEY_CTRL+1000,1.25]]]
	for row in rows.size():
		var x:=56.0
		for spec in rows[row]:
			add_key(spec[0],spec[1],Rect2(x,262+row*46,44*spec[2]-4,41));x+=44*spec[2]
	var nav=[["Prt",KEY_PRINT],["Scr",KEY_SCROLLLOCK],["Pause",KEY_PAUSE],["Ins",KEY_INSERT],["Home",KEY_HOME],["Pg↑",KEY_PAGEUP],["Del",KEY_DELETE],["End",KEY_END],["Pg↓",KEY_PAGEDOWN]]
	for i in nav.size():add_key(nav[i][0],nav[i][1],Rect2(742+(i%3)*44,262+floori(i/3.0)*46,40,41))
	add_key("↑",KEY_UP,Rect2(786,446,40,41))
	for i in 3:add_key(["←","↓","→"][i],[KEY_LEFT,KEY_DOWN,KEY_RIGHT][i],Rect2(742+i*44,492,40,41))
	var pad=[["Num",KEY_NUMLOCK,0,0,1,1],["/",KEY_KP_DIVIDE,1,0,1,1],["*",KEY_KP_MULTIPLY,2,0,1,1],["-",KEY_KP_SUBTRACT,3,0,1,1],["7",KEY_KP_7,0,1,1,1],["8",KEY_KP_8,1,1,1,1],["9",KEY_KP_9,2,1,1,1],["+",KEY_KP_ADD,3,1,1,2],["4",KEY_KP_4,0,2,1,1],["5",KEY_KP_5,1,2,1,1],["6",KEY_KP_6,2,2,1,1],["1",KEY_KP_1,0,3,1,1],["2",KEY_KP_2,1,3,1,1],["3",KEY_KP_3,2,3,1,1],["Enter",KEY_KP_ENTER,3,3,1,2],["0",KEY_KP_0,0,4,2,1],[".",KEY_KP_PERIOD,2,4,1,1]]
	for spec in pad:add_key(spec[0],spec[1],Rect2(912+spec[2]*44,308+spec[3]*46,spec[4]*44-4,spec[5]*46-5))
	UI.panel(design,Rect2(56,550,1168,82))
	var p1:=UI.label(design,"P1 · verde",Rect2(350,560,280,24),20);p1.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;p1.modulate=Color("87daba")
	var p2:=UI.label(design,"P2 · dourado",Rect2(650,560,280,24),20);p2.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;p2.modulate=Color("f1ca80")
	roles=UI.label(design,"Espaço ou W: pular  ·  E / Enter: usar  ·  Q / Shift direito: poder",Rect2(80,594,1120,24),18)
	roles.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	back=UI.button(design,"Voltar ao jogo" if embedded else "Voltar ao menu",Rect2(450,646,380,46),"back");back.pressed.connect(close)
	resized.connect(fit);fit()

## Cor, relevo e animação representam a tecla; clicar só aciona o boneco demonstrativo.
func add_key(text: String,code: int,rect: Rect2) -> void:
	var cap:=Button.new();cap.text=text;cap.position=rect.position;cap.size=rect.size;cap.focus_mode=Control.FOCUS_NONE;cap.toggle_mode=true
	cap.add_theme_font_override("font",UI.FONT);cap.add_theme_font_size_override("font_size",13 if text.length()>4 else 17)
	var owner:=key_owner(code)
	for state in ["normal","hover","pressed"]:
		var style:=StyleBoxFlat.new();style.bg_color=Color("263f4c") if owner==0 else Color("2c655e") if owner==1 else Color("715d3b")
		if state=="pressed":style.bg_color=style.bg_color.lightened(0.3)
		style.border_color=Color("60818b") if owner==0 else Color("8ee7c4") if owner==1 else Color("f1d189")
		style.set_border_width_all(1);style.border_width_bottom=4;style.set_corner_radius_all(3);cap.add_theme_stylebox_override(state,style)
	cap.button_down.connect(func():held[code]=true;strike(code));cap.button_up.connect(func():held.erase(code));design.add_child(cap);keys[code]=cap;key_count+=1

func key_owner(code: int) -> int:
	if code in [KEY_A,KEY_D,KEY_W,KEY_SPACE,KEY_E,KEY_Q]:return 1
	if code in [KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_ENTER,KEY_SHIFT+1000]:return 2
	return 0
func strike(code: int) -> void:
	active[code]=0.18
	var owner:=key_owner(code)
	if owner==0:return
	var action: String="Andar" if code in [KEY_A,KEY_D,KEY_LEFT,KEY_RIGHT] else "Pular" if code in [KEY_SPACE,KEY_W,KEY_UP] else "Usar" if code in [KEY_E,KEY_ENTER] else "Poder"
	demo_time[owner-1]=0.65;demo_action[owner-1]=action;action_labels[owner-1].text=action
	var actor:=demos[owner-1];actor.flip_h=code in [KEY_A,KEY_LEFT]
	var clip: StringName=&"walk" if action=="Andar" else &"jump_up" if action=="Pular" else &"idle"
	if actor.sprite_frames.has_animation(clip):actor.play(clip)
func _input(event: InputEvent) -> void:
	if not event is InputEventKey:return
	var code:=int(event.physical_keycode if event.physical_keycode!=0 else event.keycode)
	if code==KEY_SHIFT and event.location==KEY_LOCATION_RIGHT:code+=1000
	if event.pressed and not event.echo:held[code]=true;strike(code)
	if not event.pressed:held.erase(code)
	if event.pressed and code==KEY_ESCAPE:get_viewport().set_input_as_handled();close()
func _process(delta: float) -> void:
	elapsed+=delta
	for code in active.keys():
		active[code]=0.18 if held.has(code) else maxf(0,active[code]-delta)
		if keys.has(code):keys[code].set_pressed_no_signal(active[code]>0)
	for i in 2:
		var walking:=demo_action[i]=="Andar" and held.keys().any(func(code):return key_owner(code)==i+1 and code in [KEY_A,KEY_D,KEY_LEFT,KEY_RIGHT])
		demo_time[i]=0.65 if walking else maxf(0,demo_time[i]-delta)
		demos[i].position=demo_bases[i]-Vector2(0,roundf(sin((0.65-demo_time[i])/0.65*PI)*18) if demo_time[i]>0 and demo_action[i]=="Pular" else 0)
		if demo_time[i]==0:demos[i].play(&"idle")
func set_roles(value: String) -> void:roles.text=value
func close() -> void:
	if embedded:close_requested.emit()
	else:get_tree().change_scene_to_file(MAIN)
func fit() -> void:
	if is_instance_valid(design):UI.fit(design,size,REFERENCE)
