extends Node2D
## The original two rotary pieces, presented as one physical candy-workshop circuit.
const ART = "res://Assets/03_Objects_and_Puzzles/pixel_refinement/"
var turns: Array[int]=[1,1]
var areas: Array[Area2D]=[]
var indicators: Array[Label]=[]
var locked:=false
var root_level: Node2D
var rotors: Array[Sprite2D]=[]
var panel_material: ShaderMaterial
var conduit_texture: Texture2D
var _art_state := -1

## Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: alinhamento dos dois condutores e apresentação da energia.
func _ready() -> void:
	root_level=get_parent()
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	var panel:=_sprite("candy_circuit_backplate.png",Vector2(1328,308),false)
	# In front of the level's distant pipes, behind these sockets and the actors.
	panel.show_behind_parent=true
	conduit_texture=panel.texture
	panel_material=ShaderMaterial.new()
	panel_material.shader=load(ART+"circuit_receiver.gdshader")
	panel.material=panel_material
	# Their nodes/signals remain available to the existing energy terminal.
	# The backplate contains the source and receiver, so they aren't drawn twice.
	root_level.get_node("Battery").hide()
	root_level.get_node("EnergyIndicator").hide()
	for i in 2:
		var at:=Vector2(1432+i*88,354)
		_sprite("candy_circuit_housing.png",at,true)
		rotors.append(_sprite("candy_circuit_rotor.png",at,true))
		var area:=Area2D.new();area.position=at;area.collision_layer=0;area.collision_mask=2
		var shape:=CollisionShape2D.new();var rect:=RectangleShape2D.new();rect.size=Vector2(68,70);shape.shape=rect;area.add_child(shape)
		var prompt:=Label.new();prompt.position=Vector2(-24,-98);prompt.add_theme_font_size_override("font_size",14)
		prompt.add_theme_constant_override("outline_size",3);area.add_child(prompt);indicators.append(prompt)
		add_child(area);areas.append(area)
	_sync_art()

## Cria o sprite local mantendo sua escala nativa e referência de textura.
func _sprite(file: String,at: Vector2,center: bool) -> Sprite2D:
	var sprite:=Sprite2D.new();sprite.texture=load(ART+file)
	sprite.position=at;sprite.centered=center;add_child(sprite)
	return sprite

## Retorna se os dois condutores estão na orientação que permite conectar energia.
func solved() -> bool:return turns==[0,0]

## Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: alinhamento dos dois condutores e apresentação da energia.
func _process(_delta: float) -> void:
	for i in 2:
		indicators[i].text=""
		if locked:continue
		for actor in [root_level.finn,root_level.bmo]:
			if not actor.has_ability(&"lever") or actor.movement_locked or not areas[i].overlaps_body(actor):continue
			indicators[i].text=("E" if actor.player_id==1 else "Enter")+": girar"
			if Input.is_action_just_pressed(actor.get_interact_action()):turns[i]=1-turns[i]
	if root_level.energy_terminal.energized and not locked:locked=true
	_sync_art()

## Atualiza orientação e receptor somente quando o estado visual muda.
func _sync_art() -> void:
	var state:=turns[0]+turns[1]*2+(4 if locked else 0)
	if state==_art_state:return
	_art_state=state
	for i in rotors.size():
		# Exact quarter turns preserve native pixels and make the broken route visible.
		rotors[i].rotation=0 if turns[i]==0 else PI*0.5
		rotors[i].modulate=Color.WHITE if locked else Color("e2d4bd")
	panel_material.set_shader_parameter("powered",locked)
	queue_redraw()

## Desenha a apresentação local; este método não concede progresso nem altera colisões. Contexto: alinhamento dos dois condutores e apresentação da energia.
func _draw() -> void:
	# Continuous sockets join the two interactive housings to the source/receiver.
	# Decoration only: no new input, puzzle conditions or collision.
	for span in [[1372,1408],[1456,1496],[1544,1570]]:
		var x: int=span[0];var width: int=span[1]-span[0]
		for offset in range(0,width,24):
			var length:=mini(24,width-offset)
			draw_texture_rect_region(conduit_texture,Rect2(x+offset,350,length,8),Rect2(72,66,length,8))
