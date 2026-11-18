extends Node2D
## Nuvens e brilhos em sprites discretos; nunca movem colisões ou indicam interação.
@export_range(1,6) var phase:=1
const ART="res://Assets/03_Objects_and_Puzzles/cohesion_18_11/"
var clock:=0.0
var shadows: Node2D
var drift: Node2D
var clouds: Array[Sprite2D]=[]
var lights: Array[AnimatedSprite2D]=[]
func _ready() -> void:
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	shadows=Node2D.new();shadows.z_index=-1;shadows.draw.connect(draw_shadows);add_child(shadows)
	drift=Node2D.new();drift.z_index=-7;add_child(drift)
	if phase in [1,2,6]:
		for i in 4:
			var cloud:=Sprite2D.new();cloud.texture=load(ART+"ambient_cloud.png");cloud.modulate=Color(0.8,0.9,1.0,0.15) if phase!=6 else Color(0.9,0.65,0.8,0.12);drift.add_child(cloud);clouds.append(cloud)
	var frames:=SpriteFrames.new();frames.remove_animation(&"default");frames.add_animation(&"glint");frames.set_animation_speed(&"glint",2.5)
	for i in 4:
		var frame:=AtlasTexture.new();frame.atlas=load(ART+"ambient_glint.png");frame.region=Rect2(i*8,0,8,8);frames.add_frame(&"glint",frame)
	for i in 10:
		var light:=AnimatedSprite2D.new();light.sprite_frames=frames;light.modulate={1:Color("cadc8860"),2:Color("dce9f066"),3:Color("98d6cf66"),4:Color("edbb715c"),5:Color("e9d7ab50"),6:Color("b1e0cb60")}[phase]
		drift.add_child(light);light.play(&"glint");light.frame=i%4;lights.append(light)
func _process(delta: float) -> void:
	clock+=delta;shadows.queue_redraw()
	for i in clouds.size():clouds[i].position=Vector2(fmod(i*637+clock*(2+i%2),2780)-90,90+i%3*37).round()
	for i in lights.size():lights[i].position=Vector2(fmod(i*239+clock*(1.5+phase*0.3),2600),200+fmod(i*47+clock*(1.2 if phase!=2 else 3.0),170)).round()
func draw_shadows() -> void:
	for actor in get_tree().get_nodes_in_group("players"):
		if not actor.is_visible_in_tree() or not actor.is_on_floor():continue
		var shape: CollisionShape2D=actor.get_node("CollisionShape2D")
		var feet:=shape.global_transform*Vector2(0,shape.shape.size.y*0.5)
		shadows.draw_rect(Rect2(shadows.to_local(feet).round()-Vector2(12,1),Vector2(24,2)),Color("132b3a50"))
