@tool
extends Node2D
## Local layout additions: readable upper routes and a two-player confirmation in the cave.
@export_range(2,4) var region:=3
var confirmation_solved:=false
var plates: Array[PressurePlate]=[]
var checkpoint: bool=false
var root_level: Node2D
var palette:=Color("72b9b3")
func _ready() -> void:
	root_level=get_parent()
	if region==3:
		platform("LowerApproach",Vector2(384,336),64)
		platform("MusicBalcony",Vector2(512,280),112)
		platform("EchoIslandNear",Vector2(1376,370),96)
		platform("EchoIslandFar",Vector2(1488,338),96)
	elif region==4:
		platform("LowerServiceWalk",Vector2(944,324),96)
		platform("UpperServiceWalk",Vector2(1072,264),112)
		platform("ReturnServiceWalk",Vector2(1200,324),80)
	if not Engine.is_editor_hint():_configure.call_deferred()

func platform(label: String,at: Vector2,width: int) -> void:
	var body:=StaticBody2D.new();body.name=label;body.position=at;body.collision_layer=1;body.collision_mask=0
	var shape:=CollisionShape2D.new();var rectangle:=RectangleShape2D.new();rectangle.size=Vector2(width,8)
	shape.shape=rectangle;shape.position.y=4;body.add_child(shape)
	var kind: String="03_musical_cave" if region==3 else "04_candy_workshop"
	var texture:=load("res://Assets/02_Environments/"+kind+"/tiles/platform.png") as Texture2D
	var used:=texture.get_image().get_used_rect()
	for x in range(-width/2,width/2,32):
		var sprite:=Sprite2D.new();sprite.texture=texture;sprite.centered=false
		sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.position=Vector2(x,-used.position.y)
		# Crop the last tile to its physical support width; never stretch pixels.
		sprite.region_enabled=true
		sprite.region_rect=Rect2(0,0,mini(32,width/2-x),texture.get_height())
		body.add_child(sprite)
	add_child(body)

func _configure() -> void:
	if region==3:
		var ground: TileMapLayer=root_level.get_node("TileMapLayer")
		for cell in ground.get_used_cells():
			if cell.x>=42 and cell.x<=47:ground.erase_cell(cell)
		root_level.get_node("EnergyTerminal").position.y=306
		for x in [1712,1808]:
			var plate:=load("res://pressure_plate.tscn").instantiate() as PressurePlate
			plate.name="DuetPlate"+str(x);plate.position=Vector2(x,394)
			add_child(plate);plates.append(plate)
			var sprite:=plate.get_node("Sprite2D") as Sprite2D
			var used:=sprite.texture.get_image().get_used_rect()
			sprite.position.y=-(used.end.y-sprite.texture.get_height()*0.5)
			plate.activation_changed.connect(_check_duet)
	# The crystal is visibly dormant until the existing mechanisms are solved.
	var crystal:=root_level.get_node("FriendshipCrystal") as FriendshipCrystal
	crystal.monitoring=false
	var surfaces: Dictionary
	if region==3:
		surfaces={"SymbolTerminal/Sprite2D":394,"EnergyTerminal/Sprite2D":338,"MusicPanel/Sprite2D":280,"Battery":394,"EnergyIndicator":394,"Checkpoint/Sprite2D":394,"CooperativeExit/Sprite2D":394}
	else:
		surfaces={"EnergyTerminal/Sprite2D":388,"TransportTerminal/Sprite2D":388,"Battery":388,"EnergyIndicator":388,"Checkpoint/Sprite2D":388,"CooperativeExit/Sprite2D":388}
	# Native pixel size locally; the shared checkpoint scene and its area stay intact.
	root_level.get_node("Checkpoint/Sprite2D").scale=Vector2.ONE
	for path in surfaces:_ground_fixture(path,surfaces[path])
	root_level.get_node("RegionalScenery").queue_redraw()
	crystal.get_node("Sprite2D").texture=load("res://Assets/03_Objects_and_Puzzles/sprites/crystal_"+("purple" if region==3 else "orange")+".png")
	crystal.get_node("Sprite2D").texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST

func _check_duet(_active: bool) -> void:
	if plates.size()!=2 or confirmation_solved:return
	if plates[0].is_active() and plates[1].is_active():
		confirmation_solved=true
		for plate in plates:plate.modulate=Color("e0fff1")

func _process(_delta: float) -> void:
	if Engine.is_editor_hint() or root_level==null:return
	if region==3 and confirmation_solved:
		for plate in plates:plate.plate_sprite.texture=plate.pressed_texture
	var crystal:=root_level.get_node_or_null("FriendshipCrystal") as FriendshipCrystal
	if crystal==null or crystal.is_collected:return
	var available: bool
	if region==3:available=root_level.get_node("MusicGate").is_open and root_level.symbol_terminal.solved and root_level.energy_terminal.energized and confirmation_solved
	else:available=root_level.get_node("TrunkPuzzle/Gate").is_open and root_level.energy_terminal.energized
	crystal.set_deferred("monitoring",available)
	crystal.modulate=Color.WHITE if available else Color(0.5,0.6,0.7,1)

func _ground_fixture(path: String,surface: float) -> void:
	var sprite:=root_level.get_node_or_null(path) as Sprite2D
	if sprite==null:return
	sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	var used:=sprite.texture.get_image().get_used_rect()
	var edge: Vector2=sprite.global_transform*Vector2(0,used.end.y-sprite.texture.get_height()*0.5+sprite.offset.y)
	# Integral local shifts avoid introducing a new fractional-pixel animation offset.
	sprite.position.y+=roundf((surface-edge.y)/sprite.get_parent().global_scale.y)
