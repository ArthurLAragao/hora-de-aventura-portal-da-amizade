extends Control
## Vinheta entre fases, com assets locais. Animação de viagem, sem conceder progresso.
signal finished
const UI=preload("res://scripts/ui/menu_layout.gd")
const ENVS=["01_tree_house","02_ice_kingdom","03_musical_cave","04_candy_workshop","05_mirror_tower","06_friendship_portal"]
const TITLES=["Trilha da Casa na Árvore","Passagem do Reino Gelado","Caverna Musical","Oficina do Reino Doce","Torre dos Espelhos","Portal da Amizade"]
const LINES=["","O vento traz notícias do Reino Gelado.","Entre as pedras, uma melodia chama os amigos.","As luzes da oficina esperam por novas mãos.","No alto da torre, a luz procura seu caminho.","Todos os caminhos levam de volta à amizade."]
var destination:=2
var travelers: Array[String]=[]
var design: Control
var actors: Array[AnimatedSprite2D]=[]
var elapsed:=0.0
var done:=false
var skip: Button

## Constrói a passagem usando o panorama de destino e retratos existentes sem deformação.
func _ready() -> void:
	process_mode=Node.PROCESS_MODE_ALWAYS;mouse_filter=MOUSE_FILTER_STOP;set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade:=ColorRect.new();shade.color=Color("0d202b");shade.mouse_filter=MOUSE_FILTER_STOP;add_child(shade);shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	design=Control.new();design.size=Vector2(1152,648);add_child(design)
	var bg:=TextureRect.new();bg.position=Vector2(0,104);bg.size=Vector2(1152,392);bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;bg.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.texture=load("res://Assets/02_Environments/%s/background.png"%ENVS[destination-1]);bg.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;bg.modulate=Color("a9b9c2");design.add_child(bg)
	var header:=UI.label(design,"A VIAGEM CONTINUA",Rect2(32,27,1088,22),16);header.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;header.modulate=Color("e7ce92")
	var title:=UI.label(design,TITLES[destination-1],Rect2(32,54,1088,40),30);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	var caption:=UI.label(design,LINES[destination-1],Rect2(90,514,972,46),21,true);caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	# Caminho estilizado de mapa, separado da física do cenário que permanece pausado.
	var route:=Control.new();design.add_child(route);route.draw.connect(func():
		for x in range(160,996,18):route.draw_rect(Rect2(x,446,10,3),Color("f2d89a"))
		for x in [160,996]:route.draw_circle(Vector2(x,447),6,Color("f2d89a")))
	for id in travelers:
		var actor:=AnimatedSprite2D.new();actor.sprite_frames=load("res://Assets/01_Characters/%s/animations.tres"%id);actor.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		actor.scale=Vector2.ONE*2;design.add_child(actor);actor.play("walk" if actor.sprite_frames.has_animation("walk") else "idle");actors.append(actor)
	skip=UI.button(design,"Seguir viagem",Rect2(466,578,220,44),"Skip");skip.disabled=true;skip.pressed.connect(finish)
	get_viewport().size_changed.connect(fit);fit()

## A mesma composição funciona nas resoluções suportadas, com proporções preservadas.
func fit() -> void:
	UI.fit(design,get_viewport().get_visible_rect().size,Vector2(1152,648))

## Movimento curto, controlado e sem flashes; botão só arma depois da tecla de abertura solta.
func _process(delta: float) -> void:
	elapsed+=delta
	var travel:=smoothstep(0.0,1.0,minf(elapsed/4.6,1.0))
	for i in actors.size():actors[i].position=Vector2(224+travel*680-i*82,392)
	if elapsed>0.65 and skip.disabled and not UI.game_input_held():skip.disabled=false;skip.grab_focus()
	if elapsed>=5.3:finish()

## Emite uma única saída, independentemente de botão e temporizador coincidirem.
func finish() -> void:
	if done:return
	done=true;finished.emit()
