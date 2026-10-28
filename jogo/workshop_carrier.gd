extends AnimatableBody2D
## A local workshop rail. Carries only its supported marked block; waits for obstructions.
var block: PushBlock
var requested:=false
var arrived:=false
var blocked:=false
var start:=Vector2(512,388)
var target:=Vector2(640,388)
var activation_count:=0
func _ready() -> void:
	sync_to_physics=false;position=start;collision_layer=1;collision_mask=0
	var shape:=CollisionShape2D.new();var rect:=RectangleShape2D.new();rect.size=Vector2(128,10)
	shape.shape=rect;shape.position.y=5;add_child(shape)
	var tex:=load("res://Assets/02_Environments/04_candy_workshop/tiles/bridge.png") as Texture2D
	var used:=tex.get_image().get_used_rect()
	for x in [-64,-32,0,32]:
		var sprite:=Sprite2D.new();sprite.texture=tex;sprite.centered=false
		sprite.position=Vector2(x,-used.position.y);sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;add_child(sprite)
func loaded() -> bool:
	return is_instance_valid(block) and absf(block.global_position.x-global_position.x)<10 and absf(block.global_position.y+12-global_position.y)<4
func start_route() -> void:
	if requested:return
	requested=true;activation_count+=1
func _physics_process(delta: float) -> void:
	if not requested or arrived:return
	var next:=position.move_toward(target,80*delta)
	var motion:=next-position
	# Never sweep through a player's body below/in front of the platform.
	var rect:=RectangleShape2D.new();rect.size=Vector2(130+absf(motion.x),9)
	var query:=PhysicsShapeQueryParameters2D.new();query.shape=rect
	query.transform=Transform2D(0,global_position+Vector2(motion.x/2,5.5));query.collision_mask=2
	blocked=not get_world_2d().direct_space_state.intersect_shape(query,1).is_empty()
	if blocked:return
	if not loaded():return
	var load_shape:=RectangleShape2D.new();load_shape.size=Vector2(48+absf(motion.x),23.8)
	query.shape=load_shape;query.transform=Transform2D(0,block.global_position+Vector2(motion.x/2,0))
	blocked=not get_world_2d().direct_space_state.intersect_shape(query,1).is_empty()
	if blocked:return
	block.settled=true
	block.move_and_collide(motion)
	position=next
	arrived=position.distance_to(target)<0.01
	if arrived:block.settled=false

func reset_if_clear() -> bool:
	for actor in get_tree().get_nodes_in_group("players"):
		if actor is CoopPlayer and absf(actor.global_position.x-global_position.x)<86 and actor.global_position.y<420:return false
	position=start;requested=false;arrived=false;blocked=false;block.settled=false
	return true

func _draw() -> void:
	# A physical loading mark; entering it holds the block, with no repositioning.
	draw_rect(Rect2(-18,-3,36,3),Color("f7dda3"))
	for x in [-18,14]:draw_rect(Rect2(x,-7,4,7),Color("795064"))
