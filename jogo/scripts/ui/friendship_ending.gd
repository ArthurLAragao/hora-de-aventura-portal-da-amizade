extends CanvasLayer
const B=preload("res://scripts/core/journey_build.gd")
## Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: celebração final com os seis personagens.
func _ready() -> void:
	layer=12
	var shade:=ColorRect.new()
	shade.position=Vector2(0,490)
	shade.size=Vector2(1152,158)
	shade.color=Color(0.04,0.10,0.14,0.92)
	shade.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	var title=B.label(self,"Portal da Amizade restaurado!",Vector2(0,96),28)
	title.size.x=1152;title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	var sub=B.label(self,"Cada amigo trouxe uma parte. Juntos, encontramos o caminho de casa.",Vector2(0,138),16)
	sub.size.x=1152;sub.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	var top=load("res://Assets/02_Environments/06_friendship_portal/tiles/top.png")
	for i in 28:
		var tile:=Sprite2D.new()
		var region:=AtlasTexture.new();region.atlas=top;region.region=Rect2(0,17,32,10)
		tile.texture=region;tile.position=Vector2(144+i*32,559);tile.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(tile)
	var names=["Finn","Jake","Fionna","Cake","Marceline","BMO"]
	for i in 6:
		var sprite:=AnimatedSprite2D.new();sprite.name=names[i]
		sprite.sprite_frames=load("res://Assets/01_Characters/%s/animations.tres"%names[i].to_lower())
		sprite.position=Vector2(216+i*144,522);sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(sprite);sprite.play(&"celebrate" if sprite.sprite_frames.has_animation(&"celebrate") else &"idle")
		var label=B.label(self,names[i],Vector2(160+i*144,575),14);label.size.x=112;label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	for i in 2:
		var button:=Button.new();button.name="Phases" if i==0 else "Menu"
		button.text="Seleção de fases" if i==0 else "Menu"
		button.position=Vector2(384+i*200,608);button.size=Vector2(184,32);button.focus_mode=Control.FOCUS_ALL
		B.style_button(button);add_child(button)
		var focus:=button.get_theme_stylebox("normal").duplicate() as StyleBoxFlat;focus.border_color=Color("ffe69a");focus.set_border_width_all(3);button.add_theme_stylebox_override("focus",focus)
		var path: String="res://phase_select.tscn" if i==0 else "res://Assets/04_Interface/Godot/main_menu.tscn"
		button.pressed.connect(func():get_tree().change_scene_to_file(path))

	get_viewport().size_changed.connect(fit_screen)
	fit_screen()
	arm_buttons.call_deferred()

## Escala a celebração inteira, preservando proporções dos seis personagens e dos textos.
func fit_screen() -> void:
	if not is_inside_tree() or get_viewport()==null:return
	var available:=get_viewport().get_visible_rect().size
	var factor:=minf(available.x/1152.0,available.y/648.0)
	scale=Vector2.ONE*factor;offset=(available-Vector2(1152,648)*factor)*0.5

## Evita que uma tecla ainda segurada na fase escolha um botão de encerramento.
func arm_buttons() -> void:
	for child in get_children():
		if child is Button:child.disabled=true
	while preload("res://scripts/ui/menu_layout.gd").game_input_held():await get_tree().process_frame
	for child in get_children():
		if child is Button:child.disabled=false
	get_node("Phases").grab_focus()

## Oferece retorno estável ao menu também pelo teclado.
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_ESCAPE:
		get_viewport().set_input_as_handled();get_tree().change_scene_to_file("res://Assets/04_Interface/Godot/main_menu.tscn")
