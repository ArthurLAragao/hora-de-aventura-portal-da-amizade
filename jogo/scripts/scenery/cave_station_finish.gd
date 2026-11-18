extends Node2D
## Revestimento do conjunto musical: mantém terminais, pistas e posições de interação.
const ART="res://Assets/03_Objects_and_Puzzles/cohesion_18_11/"
var level: Node2D
var console: Sprite2D
var battery: Sprite2D
var receiver: Sprite2D
var previous:=-1
var receiver_frames: Array[Texture2D]=[]
func _ready() -> void:
	level=get_parent().get_parent();texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	console=fixture("EnergyTerminal/Sprite2D","cave_console.png",306)
	battery=fixture("Battery","cave_power.png",394)
	receiver=level.get_node("EnergyIndicator")
	# O ressonador fica integralmente sobre a margem, com respiro antes da placa da dupla.
	battery.global_position.x=level.to_global(Vector2(1640,0)).x;receiver.position.x=1704
	for state in ["off","on"]:receiver_frames.append(preload("res://scripts/core/journey_build.gd").receiver_texture("res://Assets/03_Objects_and_Puzzles/sprites/receiver_"+state+".png"))
	level.energy_terminal.activated.connect(sync);sync()
func fixture(path: String,file: String,floor_y: float) -> Sprite2D:
	var original: Sprite2D=level.get_node(path);original.hide()
	var art:=Sprite2D.new();art.texture=load(ART+file);art.hframes=2;art.global_position=Vector2(original.global_position.x,floor_y-30);art.z_index=-1;add_child(art);return art
func sync() -> void:
	var active: bool=level.energy_terminal.energized
	if previous==int(active):return
	previous=int(active)
	console.frame=1 if active else 0;battery.frame=1 if active else 0
	# O recorte existente remove fragmentos do atlas que falseavam a base do receptor.
	receiver.texture=receiver_frames[previous];level.get_node("RegionalLayout")._ground_fixture("EnergyIndicator",394)
func _process(_delta: float) -> void:sync()
