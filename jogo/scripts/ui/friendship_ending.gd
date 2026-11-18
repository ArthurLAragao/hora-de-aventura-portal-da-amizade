extends CanvasLayer
## Celebração final responsiva: entrada breve, emblema dos seis cristais e amigos animados.
const ART=preload("res://scripts/ui/sprite_art.gd")
const B=preload("res://scripts/core/journey_build.gd")
const UI=preload("res://scripts/ui/menu_layout.gd")
const COLORS=[Color("76d7ed"),Color("87d8a2"),Color("bf91eb"),Color("f0b26f"),Color("f0a4cd"),Color("e4ce7a")]
var friends: Array[AnimatedSprite2D]=[]
var bases: Array[Vector2]=[]
var ceremony: Node2D
var elapsed:=0.0
var crystal_sprites: Array[AnimatedSprite2D]=[]
var activation_sprites: Array[AnimatedSprite2D]=[]
var lit_count:=0

## Reaproveita os frames reais, mede os pés uma vez e mantém botões fora da animação.
func _ready() -> void:
	layer=45
	var background:=TextureRect.new();background.texture=load("res://Assets/02_Environments/06_friendship_portal/background.png");background.size=Vector2(1152,648);background.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;background.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED;background.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(background)
	var shade:=ColorRect.new();shade.name="Backdrop";shade.position=Vector2.ZERO;shade.size=Vector2(1152,648)
	shade.color=Color(0.025,0.08,0.12,0.36);shade.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(shade)
	var title:=B.label(self,"VOCÊS SALVARAM O MUNDO DE OOO!",Vector2(0,54),34);title.name="Title";title.size.x=1152;title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	var sub:=B.label(self,"Seis amigos. Seis cristais. Uma conquista de todos.",Vector2(0,106),20);sub.size.x=1152;sub.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	ceremony=Node2D.new();ceremony.name="CrystalEmblem";ceremony.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;add_child(ceremony);build_emblem()
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
	for i in 1:
		var button:=Button.new();button.name="Menu";button.text="Voltar ao menu"
		button.position=Vector2(436,590);button.size=Vector2(280,44);B.style_button(button);ART.button(button);add_child(button)
		var path: String="res://Assets/04_Interface/Godot/main_menu.tscn"
		button.pressed.connect(func():get_tree().change_scene_to_file(path))
	get_viewport().size_changed.connect(fit_screen);fit_screen();arm_buttons.call_deferred()

## Medalhão e seis cristais são PNGs/atlas; o piso usa o mesmo tile do santuário.
func build_emblem() -> void:
	var medallion:=Sprite2D.new();medallion.name="VictoryMedallion";medallion.texture=load(ART.ROOT+"victory_medallion.png");medallion.position=Vector2(576,278);medallion.scale=Vector2.ONE*1.75;ceremony.add_child(medallion)
	var sockets=[Vector2(0,-57),Vector2(48,-27),Vector2(48,28),Vector2(0,58),Vector2(-48,28),Vector2(-48,-27)]
	for i in 6:
		var at: Vector2=medallion.position+sockets[i]*1.75
		var gem:=ART.gem(ceremony,at,COLORS[i],0.8);gem.hide();crystal_sprites.append(gem)
		var fx:=ART.burst(ceremony,at,COLORS[i]);fx.hide();activation_sprites.append(fx)
	for x in range(88,1064,32):
		var floor:=Sprite2D.new();floor.texture=load("res://Assets/02_Environments/06_friendship_portal/tiles/top.png");floor.region_enabled=true;floor.region_rect=Rect2(0,20,32,12);floor.position=Vector2(x+16,512);ceremony.add_child(floor)

## Entrada escalonada e pequenos saltos de comemoração, com pousos claros na mesma base.
func _process(delta: float) -> void:
	elapsed+=delta
	for i in friends.size():
		var entrance:=clampf((elapsed-i*0.11)/0.45,0,1)
		var hop:=maxf(0,sin((elapsed-i*0.14)*3.2))*5 if elapsed>1.4 else 0.0
		friends[i].position=bases[i]+Vector2(0,roundf((1-entrance)*22-hop));friends[i].modulate.a=entrance
	while lit_count<6 and elapsed>0.25+lit_count*0.16:
		crystal_sprites[lit_count].show();activation_sprites[lit_count].show();activation_sprites[lit_count].play(&"activate");lit_count+=1

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
	get_node("Menu").grab_focus()

## Esc oferece retorno estável ao menu.
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_ESCAPE:get_viewport().set_input_as_handled();get_tree().change_scene_to_file("res://Assets/04_Interface/Godot/main_menu.tscn")
