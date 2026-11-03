extends Control
## Orientações opcionais usadas pelo menu e, sem trocar de cena, durante as fases.
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

## Monta três páginas curtas e adapta a composição à janela atual.
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	var fill:=ColorRect.new();fill.name="WindowBackdrop";fill.color=Color("081a26");fill.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(fill);fill.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	design=Control.new();design.name="Design";design.size=REFERENCE;add_child(design)
	var background:=TextureRect.new();background.texture=load("res://Assets/06_Story_Screens/discovery.png")
	background.size=REFERENCE;background.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;background.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED;background.mouse_filter=Control.MOUSE_FILTER_IGNORE;design.add_child(background)
	UI.panel(design,Rect2(48,32,1184,656))
	UI.label(design,"COMO JOGAR",Rect2(80,52,1100,48),34)
	UI.label(design,"Conversem, compartilhem as pistas e ajudem o amigo a continuar.",Rect2(80,105,1100,32),21)
	for i in 3:
		var tab:=UI.button(design,["Em dupla","Controles","Amigos"][i],Rect2(80+i*376,154,368,48),"Tab%d"%i)
		tab.toggle_mode=true;tab.pressed.connect(select_page.bind(i));tabs.append(tab)
		var page:=Control.new();page.name="Page%d"%i;design.add_child(page);pages.append(page)
	build_team_page();build_controls_page();build_friends_page()
	roles=UI.label(design,"As duplas mudam. Suas teclas continuam iguais.",Rect2(80,578,1120,28),18)
	var buttons:=Control.new();buttons.name="Buttons";design.add_child(buttons)
	back=UI.button(buttons,"Voltar ao jogo" if embedded else "Voltar ao menu",Rect2(80,614,340,48),"back")
	back.pressed.connect(close)
	if not embedded:
		var play:=UI.button(buttons,"Escolher uma fase",Rect2(860,614,340,48),"play")
		play.pressed.connect(func():get_tree().change_scene_to_file("res://phase_select.tscn"))
	resized.connect(fit);select_page(0);fit();tabs[0].grab_focus.call_deferred()

## Explica objetivo, cooperação e recuperação sem depender de textos sobre o cenário.
func build_team_page() -> void:
	var titles=["Um objetivo em comum","Cada um ajuda","Tentem de novo"]
	var texts=["Procurem o Cristal da Amizade. Depois, cheguem juntos à saída para seguir a aventura.","Um amigo abre caminho para o outro. Conversem sobre o que cada um consegue alcançar.","Uma queda traz a dupla de volta a um lugar seguro. O que vocês já resolveram fica guardado."]
	for i in 3:
		UI.panel(pages[0],Rect2(80+i*376,232,360,304))
		UI.label(pages[0],titles[i],Rect2(98+i*376,250,324,60),25,true)
		UI.label(pages[0],texts[i],Rect2(98+i*376,326,324,174),23,true)

## Apresenta os comandos reais dos dois jogadores e as ações comuns às fases.
func build_controls_page() -> void:
	for i in 2:
		UI.panel(pages[1],Rect2(80+i*568,228,552,246))
		UI.label(pages[1],"Jogador %d"%(i+1),Rect2(100+i*568,242,510,38),27)
		var text="Andar: A / D\nPular: Espaço ou W\nInteragir: E\nHabilidade: Q, quando disponível" if i==0 else "Andar: setas laterais\nPular: seta para cima\nInteragir: Enter\nHabilidade: Shift direito, quando disponível"
		UI.label(pages[1],text,Rect2(100+i*568,292,510,174),23,true)
	UI.label(pages[1],"F1: orientações · Esc: cancelar ação · F2: reiniciar a fase\nTab: próxima fala · F3: reler conversa\nFinn e Fionna: R (P1) ou Backspace (P2) repõe o objeto próximo.",Rect2(80,486,1120,84),18,true)

## Reutiliza retratos e explica brevemente o talento de cada personagem.
func build_friends_page() -> void:
	var names=["Finn","Jake","Marceline","BMO","Fionna","Cake"]
	var talents=["Empurra objetos e aciona alavancas.","Faz pontes nas âncoras. O amigo abre o caminho.","Flutua por pouco tempo e ativa painéis musicais.","Opera terminais, símbolos e conexões de energia.","Move blocos e gira manivelas.","Rasteja nos túneis e faz pontes nas âncoras."]
	for i in 6:
		var at:=Vector2(80+(i%3)*376,224+floori(i/3.0)*164)
		UI.panel(pages[2],Rect2(at,Vector2(360,154)))
		var portrait:=TextureRect.new();portrait.texture=load("res://Assets/01_Characters/%s/portrait.png"%names[i].to_lower())
		portrait.position=at+Vector2(12,28);portrait.size=Vector2(58,86);portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;portrait.mouse_filter=Control.MOUSE_FILTER_IGNORE;pages[2].add_child(portrait)
		UI.label(pages[2],names[i],Rect2(at+Vector2(84,10),Vector2(260,34)),24)
		UI.label(pages[2],talents[i],Rect2(at+Vector2(84,50),Vector2(258,98)),20,true)

## Troca apenas a página visível, preservando foco e os controles do jogo.
func select_page(index: int) -> void:
	active_page=index
	for i in 3:pages[i].visible=i==index;tabs[i].set_pressed_no_signal(i==index)
	tabs[index].grab_focus()

## Mostra a dupla atual somente quando as orientações são abertas dentro de uma fase.
func set_roles(text: String) -> void:
	roles.text=text

## Fecha a orientação pelo contexto que a abriu, sem recarregar uma fase em andamento.
func close() -> void:
	if embedded:close_requested.emit()
	else:get_tree().change_scene_to_file(MAIN)

## Preserva proporções nos formatos de janela suportados.
func fit() -> void:
	if is_instance_valid(design):UI.fit(design,size,REFERENCE)

## Permite retornar ao menu pelo teclado na tela independente.
func _unhandled_key_input(event: InputEvent) -> void:
	if not embedded and event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_ESCAPE:
		get_viewport().set_input_as_handled();close()
