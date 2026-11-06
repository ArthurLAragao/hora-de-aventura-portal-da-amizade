extends CanvasLayer
## Celebração final responsiva: entrada breve, emblema dos seis cristais e amigos animados.
const B=preload("res://scripts/core/journey_build.gd")
const UI=preload("res://scripts/ui/menu_layout.gd")
const COLORS=[Color("76d7ed"),Color("87d8a2"),Color("bf91eb"),Color("f0b26f"),Color("f0a4cd"),Color("e4ce7a")]
var friends: Array[AnimatedSprite2D]=[]
var bases: Array[Vector2]=[]
var ceremony: Node2D
var elapsed:=0.0

## Reaproveita os frames reais, mede os pés uma vez e mantém botões fora da animação.
func _ready() -> void:
	layer=45
	var shade:=ColorRect.new();shade.name="Backdrop";shade.position=Vector2.ZERO;shade.size=Vector2(1152,648)
	shade.color=Color(0.025,0.08,0.12,0.82);shade.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(shade)
	var title:=B.label(self,"Juntos, conseguimos!",Vector2(0,54),34);title.name="Title";title.size.x=1152;title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	var sub:=B.label(self,"O Portal da Amizade está restaurado.",Vector2(0,106),20);sub.size.x=1152;sub.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	ceremony=Node2D.new();ceremony.name="CrystalEmblem";ceremony.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;add_child(ceremony);ceremony.draw.connect(draw_emblem)
	var names=["Finn","Jake","Fionna","Cake","Marceline","BMO"]
	for i in 6:
		var actor:=AnimatedSprite2D.new();actor.name=names[i];actor.sprite_frames=load("res://Assets/01_Characters/%s/animations.tres"%names[i].to_lower())
		actor.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;add_child(actor)
		var clip: StringName=&"celebrate" if actor.sprite_frames.has_animation(&"celebrate") else &"idle"
		actor.play(clip)
		var frame:=actor.sprite_frames.get_frame_texture(clip,0)
		var used:=frame.get_image().get_used_rect();actor.offset.y=-(used.end.y-frame.get_height()*0.5)
		var base:=Vector2(166+i*164,506);bases.append(base);friends.append(actor);actor.position=base+Vector2(0,22);actor.modulate.a=0
		var label:=B.label(self,names[i],Vector2(base.x-66,526),17);label.size.x=132;label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	for i in 2:
		var button:=Button.new();button.name="Phases" if i==0 else "Menu";button.text="Jogar outra fase" if i==0 else "Menu"
		button.position=Vector2(370+i*220,590);button.size=Vector2(204,40);B.style_button(button);add_child(button)
		var path: String="res://phase_select.tscn" if i==0 else "res://Assets/04_Interface/Godot/main_menu.tscn"
		button.pressed.connect(func():get_tree().change_scene_to_file(path))
	get_viewport().size_changed.connect(fit_screen);fit_screen();arm_buttons.call_deferred()

## Um emblema luminoso, sombras sob os amigos e confetes discretos; sem partículas persistentes.
func draw_emblem() -> void:
	ceremony.draw_circle(Vector2(576,272),98,Color("122f3b"))
	ceremony.draw_arc(Vector2(576,272),101,0,TAU,64,Color("bda66d"),2)
	for i in 6:
		var a:=TAU*i/6-PI/2;var center:=Vector2(576,272)+Vector2(cos(a),sin(a))*65
		var points:=PackedVector2Array([center+Vector2(0,-23),center+Vector2(13,-8),center+Vector2(10,13),center+Vector2(0,23),center+Vector2(-10,13),center+Vector2(-13,-8)])
		var lit:=elapsed>0.25+i*0.16
		ceremony.draw_colored_polygon(points,COLORS[i] if lit else Color("364e59"))
		ceremony.draw_polyline(points+PackedVector2Array([points[0]]),Color("e9e1b5") if lit else Color("71858a"),2)
		if lit:ceremony.draw_line(center+Vector2(-3,-12),center+Vector2(-3,8),Color("fff3d1"),2)
	for i in 6:ceremony.draw_rect(Rect2(bases[i].x-24,506,48,3),Color("243e48"))
	ceremony.draw_rect(Rect2(88,510,976,5),Color("507a77"));ceremony.draw_rect(Rect2(88,510,976,1),Color("b4c9ab"))
	for i in 18:
		var phase:=fmod(elapsed*0.10+i*0.061,1.0)
		var at:=Vector2(104+posmod(i*137,944),166+phase*230)
		ceremony.draw_rect(Rect2(at.round(),Vector2(3,3)),Color(COLORS[i%6],0.30))

## Entrada escalonada e pequenos saltos de comemoração, com pousos claros na mesma base.
func _process(delta: float) -> void:
	elapsed+=delta
	for i in friends.size():
		var entrance:=clampf((elapsed-i*0.11)/0.45,0,1)
		var hop:=maxf(0,sin((elapsed-i*0.14)*3.2))*5 if elapsed>1.4 else 0.0
		friends[i].position=bases[i]+Vector2(0,roundf((1-entrance)*22-hop));friends[i].modulate.a=entrance
	ceremony.queue_redraw()

## Enquadra a tela inteira sem deformar o emblema, personagens ou botões.
func fit_screen() -> void:
	if not is_inside_tree():return
	var available:=get_viewport().get_visible_rect().size;var factor:=minf(available.x/1152.0,available.y/648.0)
	scale=Vector2.ONE*factor;offset=(available-Vector2(1152,648)*factor)*0.5

## A tecla da última ação nunca confirma automaticamente um botão de vitória.
func arm_buttons() -> void:
	for child in get_children():
		if child is Button:child.disabled=true
	while is_inside_tree() and (elapsed<1.3 or UI.game_input_held()):await get_tree().process_frame
	if not is_inside_tree():return
	for child in get_children():
		if child is Button:child.disabled=false
	get_node("Phases").grab_focus()

## Esc oferece retorno estável ao menu.
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_ESCAPE:get_viewport().set_input_as_handled();get_tree().change_scene_to_file("res://Assets/04_Interface/Godot/main_menu.tscn")
