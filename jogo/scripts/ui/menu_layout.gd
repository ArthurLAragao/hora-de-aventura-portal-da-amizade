extends RefCounted
## Elementos locais das telas: não altera o tema global nem a resolução do projeto.
const FONT=preload("res://Assets/08_Fonts/NotoSans.ttf")

## Cria um rótulo legível na posição definida, com quebra de linha opcional.
static func label(parent: Node,text: String,rect: Rect2,size:=22,wrap:=false) -> Label:
	var node:=Label.new()
	if wrap:node.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	node.add_theme_font_override("font",FONT);node.add_theme_font_size_override("font_size",size)
	node.text=text;node.position=rect.position;node.size=rect.size
	node.mouse_filter=Control.MOUSE_FILTER_IGNORE
	node.set_meta("screen_slot",rect);parent.add_child(node);return node

## Cria o material escuro de uma área de leitura, preservando a paleta atual.
static func panel(parent: Node,rect: Rect2) -> Panel:
	var node:=Panel.new();node.position=rect.position;node.size=rect.size;node.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var style:=StyleBoxFlat.new();style.bg_color=Color("102832f5");style.border_color=Color("95d6ba")
	style.set_border_width_all(2);style.set_corner_radius_all(6)
	node.add_theme_stylebox_override("panel",style);parent.add_child(node);return node

## Cria um botão com foco de teclado claramente desenhado.
static func button(parent: Node,text: String,rect: Rect2,name: String) -> Button:
	var node:=Button.new();node.name=name;node.text=text;node.position=rect.position;node.size=rect.size
	node.focus_mode=Control.FOCUS_ALL;node.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
	node.add_theme_font_override("font",FONT);node.add_theme_font_size_override("font_size",21)
	for state in ["normal","hover","pressed","focus"]:
		var style:=StyleBoxFlat.new();style.bg_color=Color("1d4853") if state!="normal" else Color("12313c")
		style.border_color=Color("ffe69a") if state=="focus" else Color("95d6ba")
		style.set_border_width_all(3 if state=="focus" else 2);style.set_corner_radius_all(6)
		node.add_theme_stylebox_override(state,style)
	node.set_meta("screen_slot",rect);parent.add_child(node);return node

## Ajusta uma composição completa à área disponível sem deformar imagens ou fontes.
static func fit(design: Control,available: Vector2,reference: Vector2) -> void:
	var factor:=minf(available.x/reference.x,available.y/reference.y)
	design.scale=Vector2.ONE*factor;design.position=(available-reference*factor)*0.5

## Confere as entradas dos jogadores antes de devolver controle após uma tela modal.
static func game_input_held() -> bool:
	return InputMap.get_actions().any(func(action):return (String(action).begins_with("p1_") or String(action).begins_with("p2_")) and Input.is_action_pressed(action))
