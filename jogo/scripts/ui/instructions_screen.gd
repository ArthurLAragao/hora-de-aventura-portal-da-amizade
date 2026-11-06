extends Control
## Guia visual opcional: diagramas de teclas, exemplos e talentos em cartões curtos.
signal close_requested
const UI=preload("res://scripts/ui/menu_layout.gd")
const REFERENCE=Vector2(1280,720)
const MAIN="res://Assets/04_Interface/Godot/main_menu.tscn"
@export var embedded:=false
var design: Control
var pages: Array[Control]=[]
var tabs: Array[Button]=[]
var active_page:=0
var back: Button
var roles: Label

## Mantém a navegação e o ajuste de janela usados pelo menu e pela pausa.
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	var fill:=ColorRect.new();fill.color=Color("081a26");fill.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(fill);fill.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	design=Control.new();design.name="Design";design.size=REFERENCE;add_child(design)
	image(design,"res://Assets/06_Story_Screens/discovery.png",Rect2(0,0,1280,720),true)
	UI.panel(design,Rect2(48,32,1184,656));UI.label(design,"COMO JOGAR",Rect2(80,48,1100,50),34)
	for i in 3:
		var tab:=UI.button(design,["Teclas","Em dupla","Amigos"][i],Rect2(80+i*376,114,368,44),"Tab%d"%i)
		tab.toggle_mode=true;tab.pressed.connect(select_page.bind(i));tabs.append(tab)
		var page:=Control.new();page.name="Page%d"%i;design.add_child(page);pages.append(page)
	build_controls_page();build_team_page();build_friends_page()
	roles=UI.label(design,"A dupla muda. As teclas continuam iguais.",Rect2(80,568,1120,30),18)
	back=UI.button(design,"Voltar ao jogo" if embedded else "Voltar ao menu",Rect2(80,616,340,46),"back");back.pressed.connect(close)
	if not embedded:
		UI.button(design,"Escolher uma fase",Rect2(860,616,340,46),"play").pressed.connect(func():get_tree().change_scene_to_file("res://phase_select.tscn"))
	resized.connect(fit);select_page(0);fit();tabs[0].grab_focus.call_deferred()

## Uma imagem reutilizada mantém proporção; os ícones nunca capturam entradas.
func image(parent: Node,path: String,rect: Rect2,cover:=false) -> void:
	var art:=TextureRect.new();art.texture=load(path);art.position=rect.position;art.size=rect.size
	art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED if cover else TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.mouse_filter=Control.MOUSE_FILTER_IGNORE;parent.add_child(art)

## Tecla com relevo, símbolo grande e largura realista para Espaço, Enter e Shift.
func key(parent: Node,text: String,rect: Rect2) -> void:
	var cap:=UI.panel(parent,rect);cap.set_meta("keyboard_key",text)
	var style:=StyleBoxFlat.new();style.bg_color=Color("dce6d3");style.border_color=Color("718b83")
	style.set_border_width_all(2);style.border_width_bottom=5;style.set_corner_radius_all(4);cap.add_theme_stylebox_override("panel",style)
	var label:=UI.label(parent,text,rect,20);label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color",Color("16333e"))

## Quatro ações por jogador, sem parágrafos ou nomes técnicos.
func build_controls_page() -> void:
	for player in 2:
		var x:=80+player*568;var page:=pages[0]
		UI.panel(page,Rect2(x,180,552,366));UI.label(page,"P%d"%(player+1),Rect2(x+24,192,90,40),29)
		image(page,"res://Assets/01_Characters/"+("finn" if player==0 else "jake")+"/portrait.png",Rect2(x+460,190,64,60))
		for row in 4:
			var y:=252+row*66;UI.label(page,["Andar","Pular","Usar","Poder"][row],Rect2(x+24,y+6,126,40),23)
			if row==0:
				key(page,"A" if player==0 else "←",Rect2(x+168,y,60,46));key(page,"D" if player==0 else "→",Rect2(x+238,y,60,46))
			elif row==1:
				key(page,"Espaço" if player==0 else "↑",Rect2(x+168,y,144 if player==0 else 60,46))
				if player==0:key(page,"W",Rect2(x+330,y,60,46))
			else:key(page,("E" if row==2 else "Q") if player==0 else ("Enter" if row==2 else "Shift direito"),Rect2(x+168,y,166 if player==1 else 60,46))

## Exemplos visuais do objetivo, da passagem e da saída conjunta.
func build_team_page() -> void:
	for i in 3:
		var x:=80+i*376;UI.panel(pages[1],Rect2(x,184,360,360))
		UI.label(pages[1],["1 · Encontrem","2 · Ajudem","3 · Saiam juntos"][i],Rect2(x+18,204,324,42),25)
		if i==0:image(pages[1],"res://Assets/03_Objects_and_Puzzles/sprites/crystal_pink.png",Rect2(x+116,280,128,152))
		elif i==1:
			image(pages[1],"res://Assets/01_Characters/jake/portrait.png",Rect2(x+42,275,98,130))
			image(pages[1],"res://Assets/03_Objects_and_Puzzles/sprites/wooden_bridge.png",Rect2(x+142,330,160,64))
		else:
			for j in 2:image(pages[1],"res://Assets/01_Characters/"+("finn" if j==0 else "jake")+"/portrait.png",Rect2(x+62+j*120,278,98,142))
		UI.label(pages[1],["Cristal da Amizade","Abram caminho","A dupla precisa chegar"][i],Rect2(x+18,468,324,38),21)

## Retratos e verbos curtos mostram o talento sem duplicar uma página de texto.
func build_friends_page() -> void:
	var names=["Finn","Jake","Marceline","BMO","Fionna","Cake"]
	var actions=["Empurrar · alavanca","Ponte","Flutuar · música","Símbolos · energia","Blocos · manivela","Túnel · ponte"]
	for i in 6:
		var at:=Vector2(80+(i%3)*376,180+floori(i/3.0)*188)
		UI.panel(pages[2],Rect2(at,Vector2(360,176)))
		image(pages[2],"res://Assets/01_Characters/%s/portrait.png"%names[i].to_lower(),Rect2(at+Vector2(12,24),Vector2(86,124)))
		UI.label(pages[2],names[i],Rect2(at+Vector2(112,24),Vector2(230,36)),26)
		UI.label(pages[2],actions[i],Rect2(at+Vector2(112,76),Vector2(226,72)),21,true)

## Troca apenas a página visível e preserva navegação por teclado.
func select_page(index: int) -> void:
	active_page=index
	for i in 3:pages[i].visible=i==index;tabs[i].set_pressed_no_signal(i==index)
	tabs[index].grab_focus()

## A ajuda embutida recebe os nomes reais da dupla ativa.
func set_roles(text: String) -> void:roles.text=text
## Devolve controle ao contexto que abriu a ajuda.
func close() -> void:
	if embedded:close_requested.emit()
	else:get_tree().change_scene_to_file(MAIN)
## Conserva proporção em janelas largas e em 4:3.
func fit() -> void:
	if is_instance_valid(design):UI.fit(design,size,REFERENCE)
## Esc retorna quando o guia é aberto como tela independente.
func _unhandled_key_input(event: InputEvent) -> void:
	if not embedded and event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_ESCAPE:get_viewport().set_input_as_handled();close()
