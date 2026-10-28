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
		platform("LowerApproach",Vector2(384,332),64)
		platform("MusicBalcony",Vector2(512,276),112)
		platform("CrystalLookout",Vector2(1424,314),96)
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
		sprite.position=Vector2(x,-used.position.y);body.add_child(sprite)
	add_child(body)

func _configure() -> void:
	if region==3:
		for x in [1712,1808]:
			var plate:=load("res://pressure_plate.tscn").instantiate() as PressurePlate
			plate.name="DuetPlate"+str(x);plate.position=Vector2(x,388)
			add_child(plate);plates.append(plate)
			var sprite:=plate.get_node("Sprite2D") as Sprite2D
			var used:=sprite.texture.get_image().get_used_rect()
			sprite.position.y=-(used.end.y-sprite.texture.get_height()*0.5)
			plate.activation_changed.connect(_check_duet)
	# The crystal is visibly dormant until the existing mechanisms are solved.
	var crystal:=root_level.get_node("FriendshipCrystal") as FriendshipCrystal
	crystal.monitoring=false

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
