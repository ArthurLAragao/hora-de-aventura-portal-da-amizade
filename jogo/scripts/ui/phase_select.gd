extends Control
## Destinos ilustrados com progresso real e desbloqueio sequencial da campanha.
const UI=preload("res://scripts/ui/menu_layout.gd")
const PROGRESS=preload("res://scripts/core/campaign_progress.gd")
const DESIGN_SIZE=Vector2(1280,720)
const MENU_SCENE="res://Assets/04_Interface/Godot/main_menu.tscn"
const REGIONS=["01_tree_house","02_ice_kingdom","03_musical_cave","04_candy_workshop","05_mirror_tower","06_friendship_portal"]
const TITLES=["Casa na Árvore","Reino Gelado","Caverna Musical","Oficina Doce","Torre dos Espelhos","Portal da Amizade"]
const PAIRS=["Finn e Jake","Fionna e Cake","Marceline e BMO","Finn e BMO","Marceline e Cake","Os seis amigos"]
var _design: Control
var cards: Array[Button]=[]
var confirm: ConfirmationDialog
var elapsed:=0.0
var accents: Node2D

func _ready() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT);texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	var fill:=ColorRect.new();fill.color=Color("0d2530");add_child(fill);fill.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_design=Control.new();_design.name="Design";_design.size=DESIGN_SIZE;add_child(_design)
	var background:=TextureRect.new();background.texture=load("res://Assets/06_Story_Screens/discovery.png");background.size=DESIGN_SIZE;background.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;background.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED;background.modulate=Color("708879");background.mouse_filter=MOUSE_FILTER_IGNORE;_design.add_child(background)
	UI.label(_design,"O CAMINHO DA AMIZADE",Rect2(62,26,1160,44),32)
	UI.label(_design,"Um cristal. Uma descoberta. O próximo destino.",Rect2(62,76,1160,28),19)
	var data:=PROGRESS.read()
	for i in 6:
		var at:=Vector2(62+(i%3)*390,128+floori(i/3.0)*226)
		var card:=UI.button(_design,"",Rect2(at,Vector2(374,210)),"Phase%d"%(i+1));card.clip_contents=true;cards.append(card)
		var unlocked:=PROGRESS.unlocked(i+1);card.disabled=not unlocked
		var picture:=TextureRect.new();picture.texture=load("res://Assets/02_Environments/"+REGIONS[i]+"/background.png");picture.position=Vector2(3,3);picture.size=Vector2(368,150);picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED;picture.mouse_filter=MOUSE_FILTER_IGNORE;card.add_child(picture)
		if not unlocked:picture.modulate=Color("65727c")
		var strip:=ColorRect.new();strip.position=Vector2(3,148);strip.size=Vector2(368,60);strip.color=Color("102a34f5");strip.mouse_filter=MOUSE_FILTER_IGNORE;card.add_child(strip)
		UI.label(card,"%d · %s"%[i+1,TITLES[i]],Rect2(14,154,346,26),21)
		UI.label(card,PAIRS[i] if unlocked else "Conclua a fase %d"%i,Rect2(14,182,346,22),15).modulate=Color("bfd3c9")
		if i+1 in data.completed:UI.label(card,"✓",Rect2(332,10,30,36),28).modulate=Color("e2db99")
		elif not unlocked:
			var lock:=Node2D.new();lock.position=Vector2(184,70);lock.draw.connect(func():lock.draw_arc(Vector2.ZERO,12,PI,TAU,12,Color("f2dcab"),4);lock.draw_rect(Rect2(-16,0,32,25),Color("17333f"));lock.draw_rect(Rect2(-13,3,26,19),Color("d2b984"));lock.draw_rect(Rect2(-2,8,4,9),Color("17333f")));card.add_child(lock)
		card.pressed.connect(open_phase.bind(i+1))
	accents=Node2D.new();accents.z_index=2;accents.draw.connect(draw_accents);_design.add_child(accents)
	UI.button(_design,"Voltar ao menu",Rect2(62,622,300,48),"Back").pressed.connect(func():get_tree().change_scene_to_file(MENU_SCENE))
	UI.button(_design,"Nova aventura",Rect2(920,622,300,48),"NewAdventure").pressed.connect(func():confirm.popup_centered())
	confirm=ConfirmationDialog.new();confirm.title="Começar de novo?";confirm.dialog_text="Isso apaga os cristais e as fases liberadas neste computador.";confirm.ok_button_text="Nova aventura";confirm.cancel_button_text="Continuar aventura";add_child(confirm)
	confirm.confirmed.connect(func():PROGRESS.reset();get_tree().reload_current_scene())
	resized.connect(_fit_design);_fit_design();cards[0].grab_focus.call_deferred()
func open_phase(number: int) -> void:
	if PROGRESS.unlocked(number):get_tree().change_scene_to_file("res://level_%d.tscn"%number)
## Folhas na trilha, flocos no gelo e pontos de luz na caverna; todos presos aos cartões.
func draw_accents() -> void:
	for i in 3:
		for j in 6:
			var at:=Vector2(76+i*390+fmod(j*59+elapsed*(8+i*4),336),144+fmod(j*23+elapsed*(5+i*3),122))
			accents.draw_rect(Rect2(at.round(),Vector2(4 if i==0 else 2,2)),[Color("b0ca78"),Color("def2f1"),Color("bc9dd6")][i])
func _process(delta: float) -> void:elapsed+=delta;accents.queue_redraw()
func _fit_design() -> void:
	if is_instance_valid(_design):UI.fit(_design,size,DESIGN_SIZE)
