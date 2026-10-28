@tool
extends Node2D
## Art-only layers. No colliders, input or progression.
var level: Node2D
var forest:=false
var last_state:=""
const PIXELS=preload("res://scripts/scenery/pixel_environment.gd")
const ENVS="res://Assets/02_Environments/"
## Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: camadas decorativas das fases 1 e 6.
func _ready() -> void:
	level=get_parent()
	forest=level.has_node("TutorialLog")
	z_index=0
	var old=level.get_node_or_null("Scenery")
	if old!=null:
		for child in old.get_children(): child.queue_free()
	if forest:
		level.get_node("Background/Panorama").scale=Vector2.ONE*2.0
		for spec in [[32,level.LEFT_FLOOR,194],[244,level.LEFT_FLOOR,180],[1124,level.FLOOR,224],[1240,level.FLOOR,176],[1994,level.FLOOR,210]]: tree_sprite(spec[0],spec[1],spec[2])
		for spec in [[32,1,1],[72,3,1],[240,2,1],[470,3,1],[970,1,1],[1120,2,2],[1154,3,1],[1216,1,1],[1270,4,1],[1970,1,2],[2012,3,1],[2158,2,1],[2394,1,2]]:
			plant(spec[0],level.LEFT_FLOOR if spec[0]<640 else level.FLOOR,spec[1],spec[2])
	else:
		for spec in [[32,3],[88,2],[288,4],[344,2],[1144,3],[1192,4],[1328,1],[1360,2]]:
			plant(spec[0],level.LEFT_FLOOR if spec[0]<480 else level.FLOOR,spec[1],1)
	# Deliberate clearings around switches, anchors and exits; layered vegetation between them.
	if forest:
		for spec in [[100,128],[220,128],[976,96],[1180,128],[1456,96],[1976,128],[2390,96]]:
			thicket(spec[0],level.LEFT_FLOOR if spec[0]<640 else level.FLOOR,spec[1],Color(0.82,0.90,0.80),-2)
		for spec in [[60,2],[266,3],[492,2],[1090,3],[1280,2],[1508,3],[1632,2],[1930,3],[2160,3],[2408,2]]:
			plant(spec[0],level.LEFT_FLOOR if spec[0]<640 else level.FLOOR,spec[1],1)
	else:
		thicket(144,level.LEFT_FLOOR,256,Color(0.70,0.82,0.90),-4)
		for spec in [[304,192],[408,64],[1120,128],[1288,176]]:
			thicket(spec[0],level.LEFT_FLOOR if spec[0]<480 else level.FLOOR,spec[1],Color.WHITE,-2)
	queue_redraw()
## Adiciona vegetação nativa com raiz apoiada e movimento decorativo sutil.
func thicket(x: float,floor_y: float,width: int,tint: Color,plane: int) -> void:
	var tex:=PIXELS.texture("forest" if forest else "portal",width)
	var used:=tex.get_image().get_used_rect()
	var sprite:=Sprite2D.new();sprite.name="Thicket%d"%int(x)
	sprite.texture=tex;sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position=Vector2(x,floor_y-(used.end.y-tex.get_height()*0.5))
	sprite.z_index=plane;sprite.modulate=tint
	sprite.set_meta("support_y",floor_y)
	var breeze:=ShaderMaterial.new();breeze.shader=load("res://foliage_breeze.gdshader")
	breeze.set_shader_parameter("phase",x*0.029)
	breeze.set_shader_parameter("amplitude",0.7)
	breeze.set_shader_parameter("foot_y",float(used.end.y)/tex.get_height())
	sprite.material=breeze;add_child(sprite)
## Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: camadas decorativas das fases 1 e 6.
func _process(_dt: float) -> void:
	if level==null:return
	if forest and not Engine.is_editor_hint() and level.has_node("SharedCamera"):
		# Modest distant parallax inside the existing raster's spare border; no repeat or camera change.
		var center: Vector2=level.get_node("SharedCamera").get_screen_center_position()
		level.get_node("Background/Panorama").position.x=576.0-clampf((center.x-576.0)*0.04,0.0,52.0)
	var state: String=str(level.tutorial_solved)+str(level.relay_solved) if forest else str(level.repaired)
	if state!=last_state:last_state=state;queue_redraw()
## Alinha a planta pela região opaca da textura; sua decoração não recebe colisão.
func plant(x: float,floor_y: float,index: int,scale_factor: float) -> void:
	var path:=ENVS+("01_tree_house" if forest else "06_friendship_portal")+"/tiles/decor_%02d.png"%index
	var texture=load(path) as Texture2D
	var image=texture.get_image()
	var used:=image.get_used_rect()
	var sprite:=Sprite2D.new()
	sprite.name="GroundedPlant%d"%get_child_count()
	sprite.texture=texture
	sprite.scale=Vector2.ONE*scale_factor
	sprite.position=Vector2(x,floor_y-(used.end.y-texture.get_height()*0.5)*scale_factor)
	sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.set_meta("support_y",floor_y)
	if forest:
		var breeze:=ShaderMaterial.new()
		breeze.shader=load("res://foliage_breeze.gdshader")
		breeze.set_shader_parameter("phase",x*0.037)
		breeze.set_shader_parameter("foot_y",float(used.end.y)/texture.get_height())
		breeze.set_shader_parameter("amplitude",0.65/scale_factor)
		sprite.material=breeze
	add_child(sprite)
## Configura o recorte da árvore e seu movimento decorativo, preservando o apoio visual.
func tree_sprite(x: float,floor_y: float,height: float) -> void:
	var source=load("res://Assets/02_Environments/01_tree_house/tree_midground_v2.png")
	var crop:=AtlasTexture.new();crop.atlas=source;crop.region=Rect2(12,49,1067,1347)
	var sprite:=Sprite2D.new();sprite.name="Tree%d"%int(x)
	sprite.texture=crop;sprite.scale=Vector2.ONE*(height/1347.0)
	sprite.position=Vector2(x,floor_y-height*0.5);sprite.z_index=-3
	sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.set_meta("support_y",floor_y)
	var breeze:=ShaderMaterial.new()
	breeze.shader=load("res://foliage_breeze.gdshader")
	breeze.set_shader_parameter("phase",x*0.021)
	breeze.set_shader_parameter("foot_y",1.0)
	breeze.set_shader_parameter("amplitude",1.2/sprite.scale.x)
	sprite.material=breeze
	add_child(sprite)
## Desenha a apresentação local; este método não concede progresso nem altera colisões. Contexto: camadas decorativas das fases 1 e 6.
func _draw() -> void:
	if level==null:return
	if forest:
		# Inlaid links pair each weight socket to its gate, below the walking surface.
		for spec in [[446,486,level.LEFT_FLOOR,level.tutorial_solved],[1902,2022,level.FLOOR,level.relay_solved]]:
			var color:=Color("a5d6aa") if spec[3] else Color("a0804d")
			for x in range(spec[0],spec[1],10):draw_line(Vector2(x,spec[2]+11),Vector2(x+6,spec[2]+11),color,2)
		for spec in [[544,level.LEFT_FLOOR-65,level.tutorial_solved],[2080,level.FLOOR-65,level.relay_solved]]:
			if not spec[2]:
				draw_rect(Rect2(spec[0]-8,spec[1],16,14),Color("263d3e"))
				draw_rect(Rect2(spec[0]-5,spec[1]+3,10,7),Color("c49a54"))
		# Short wooden trail edging sits below the walk surface; it never suggests a platform.
		for span in [[16,248,level.LEFT_FLOOR],[1100,1240,level.FLOOR],[2140,2400,level.FLOOR]]:
			for x in range(span[0],span[1],24):
				draw_rect(Rect2(x,span[2]+12,18,5),Color("614b35"))
				draw_line(Vector2(x+2,span[2]+13),Vector2(x+14,span[2]+13),Color("a17e4c"),1)
	else:
		# Repeated masonry motif ties the sanctuary into the ground, below the grass lip.
		for span in [[16,464,level.LEFT_FLOOR],[624,1360,level.FLOOR]]:
			for x in range(span[0],span[1],48):
				draw_line(Vector2(x,span[2]+18),Vector2(x+30,span[2]+18),Color("487a87"),2)
				draw_rect(Rect2(x+12,span[2]+15,4,6),Color("77b7b1"))
