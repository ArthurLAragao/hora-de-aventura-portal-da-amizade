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
	var sub=B.label(self,"Seis amigos. Um caminho construído juntos.",Vector2(0,138),16)
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
		button.position=Vector2(384+i*200,608);button.size=Vector2(184,32);button.focus_mode=Control.FOCUS_NONE
		B.style_button(button);add_child(button)
		var path: String="res://phase_select.tscn" if i==0 else "res://Assets/04_Interface/Godot/main_menu.tscn"
		button.pressed.connect(func():get_tree().change_scene_to_file(path))
