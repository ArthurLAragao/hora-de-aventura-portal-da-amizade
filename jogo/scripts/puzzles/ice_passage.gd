extends AnimatableBody2D
## Passarela telescópica local: somente o trecho desenhado oferece apoio; nunca recolhe.
@export var direction:=1
@export var length:=192.0
var requested:=false
var extended:=false
var blocked:=false
var visible_length:=0.0
var body_shape: CollisionShape2D
var plank: Texture2D
var used: Rect2i

## Substitui a apresentação curta mantendo a mesma interface usada pela manivela.
func _ready() -> void:
	sync_to_physics=false;collision_layer=0;collision_mask=0
	$Sprite2D.hide();body_shape=$CollisionShape2D;body_shape.shape=body_shape.shape.duplicate()
	plank=load("res://Assets/02_Environments/02_ice_kingdom/tiles/bridge.png")
	used=plank.get_image().get_used_rect();texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST

## Solicita uma única extensão permanente.
func extend_passage() -> void:requested=true

## A ponta espera por corpos ocupando o próximo segmento; os jogadores mantêm controle.
func _physics_process(delta: float) -> void:
	if not requested or extended:return
	var advance:=minf(120*delta,length-visible_length)
	var probe:=RectangleShape2D.new();probe.size=Vector2(advance+2,8)
	var query:=PhysicsShapeQueryParameters2D.new();query.shape=probe;query.collision_mask=2
	query.transform=Transform2D(0,global_position+Vector2(direction*(visible_length+advance*0.5),8))
	blocked=not get_world_2d().direct_space_state.intersect_shape(query,1).is_empty()
	if blocked:return
	visible_length+=advance;body_shape.shape.size=Vector2(visible_length,12)
	body_shape.position=Vector2(direction*visible_length*0.5,6);collision_layer=1
	extended=visible_length>=length;queue_redraw()

## Tiles inteiros e recorte da ponta; o topo desenhado coincide com o apoio em Y=0.
func _draw() -> void:
	if plank==null:return
	var left: float=0 if direction>0 else -visible_length
	var cursor:=0.0
	while cursor<visible_length:
		var width:=minf(32,visible_length-cursor)
		draw_texture_rect_region(plank,Rect2(left+cursor,0,width,12),Rect2(used.position.x,used.position.y,width,12))
		cursor+=width
