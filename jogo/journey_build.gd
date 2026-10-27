extends RefCounted
const FONT=preload("res://Assets/08_Fonts/NotoSans.ttf")
const OBJECTS="res://Assets/03_Objects_and_Puzzles/sprites/"
const ACTORS={"Finn":"res://player1.tscn","Jake":"res://player_2.tscn","Fionna":"res://Assets/01_Characters/fionna/playable.tscn","Cake":"res://Assets/01_Characters/cake/playable.tscn","Marceline":"res://Assets/01_Characters/marceline/visual.tscn","BMO":"res://Assets/01_Characters/bmo/playable.tscn"}

static func label(parent: Node,text: String,position: Vector2,size: int=15,name: String="") -> Label:
	var node:=Label.new()
	if name!="": node.name=name
	node.text=text
	node.position=position
	node.add_theme_font_override("font",FONT)
	node.add_theme_font_size_override("font_size",size)
	node.add_theme_color_override("font_outline_color",Color("122433"))
	node.add_theme_constant_override("outline_size",4)
	parent.add_child(node)
	return node

static func sprite(parent: Node,name: String,path: String,position: Vector2,scale: float=1.0) -> Sprite2D:
	var node:=Sprite2D.new()
	node.name=name
	node.texture=receiver_texture(path) if "receiver_" in path else load(path)
	if "receiver_" in path: node.offset.y=-8
	node.position=position
	node.scale=Vector2.ONE*scale
	node.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(node)
	return node

static func packed(parent: Node,name: String,path: String,position: Vector2) -> Node2D:
	var node=load(path).instantiate()
	node.name=name
	node.position=position
	parent.add_child(node)
	return node

static func actor(parent: Node,name: String,position: Vector2,role: int) -> CoopPlayer:
	var node=load(ACTORS[name]).instantiate()
	node.name=name
	node.position=position
	node.player_id=role
	parent.add_child(node)
	node.set_meta("player_id",role)
	return node

static func collider(parent: Node,size: Vector2,position: Vector2=Vector2.ZERO) -> CollisionShape2D:
	var node:=CollisionShape2D.new()
	node.name="CollisionShape2D"
	var shape:=RectangleShape2D.new()
	shape.size=size
	node.shape=shape
	node.position=position
	parent.add_child(node)
	return node

static func area(parent: Node,name: String,position: Vector2,size: Vector2) -> Area2D:
	var node:=Area2D.new()
	node.name=name
	node.position=position
	node.collision_layer=0
	node.collision_mask=2
	collider(node,size)
	parent.add_child(node)
	return node

static func wall(parent: Node,name: String,position: Vector2,size: Vector2) -> StaticBody2D:
	var node:=StaticBody2D.new()
	node.name=name
	node.position=position
	node.collision_layer=1
	node.collision_mask=0
	collider(node,size)
	parent.add_child(node)
	return node

static func plate(parent: Node,name: String,position: Vector2,ability: StringName=&"",pushable: bool=false):
	var node=load("res://pressure_plate.tscn").instantiate()
	node.set_script(load("res://journey_plate.gd"))
	node.name=name
	node.position=position
	node.required_ability=ability
	node.visual_kind=&"weight" if pushable else &"step"
	node.accepts_players=not pushable
	node.accepts_pushables=pushable
	node.get_node("Sprite2D").position=Vector2(0,-4)
	parent.add_child(node)
	return node

static func log_block(parent: Node,name: String,x: float,floor_y: float) -> PushBlock:
	var node=load("res://push_block.tscn").instantiate()
	node.name=name
	node.require_support=true
	node.position=Vector2(x,floor_y-15)
	var shape:=RectangleShape2D.new()
	shape.size=Vector2(58,30)
	node.get_node("CollisionShape2D").shape=shape
	node.get_node("Sprite2D").position=Vector2(0,-14)
	parent.add_child(node)
	return node

static func gate(parent: Node,name: String,x: float,floor_y: float,height: float=80) -> CoopGate:
	var node=load("res://gate.tscn").instantiate()
	node.name=name
	node.position=Vector2(x,floor_y-height*0.5)
	var factor:=maxi(1,roundi(height/52.0))
	var actual_height:=52.0*factor
	node.position.y=floor_y-actual_height*0.5
	var shape:=RectangleShape2D.new()
	shape.size=Vector2(58,52)*factor
	node.get_node("CollisionShape2D").shape=shape
	for property in ["closed_texture","open_texture"]:
		var crop:=AtlasTexture.new()
		crop.atlas=node.get(property)
		crop.region=Rect2(3,9,58,52)
		node.set(property,crop)
	var sprite=node.get_node("Sprite2D")
	sprite.texture=node.closed_texture
	sprite.position=Vector2.ZERO
	sprite.scale=Vector2.ONE*factor
	sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(node)
	return node

static func tilemap(parent: Node,name: String,path: String,offset: Vector2=Vector2.ZERO) -> TileMap:
	var node:=TileMap.new()
	node.name=name
	node.tile_set=load(path)
	node.position=offset
	parent.add_child(node)
	return node

static func fill(map: TileMap,source: int,start: int,end: int,top: int,bottom: int) -> void:
	for x in range(start,end):
		for y in range(top,bottom): map.set_cell(0,Vector2i(x,y),source,Vector2i(1,0 if y==top else 1))

static func background(parent: Node,path: String) -> void:
	var layer:=CanvasLayer.new()
	layer.name="Background"
	layer.layer=-20
	parent.add_child(layer)
	sprite(layer,"Panorama",path,Vector2(576,324),1.8)

static func hud(parent: Node,title: String) -> CanvasLayer:
	var layer:=CanvasLayer.new()
	layer.name="HUD"
	layer.layer=10
	parent.add_child(layer)
	var panel:=Panel.new()
	panel.position=Vector2(16,14)
	panel.size=Vector2(480,60)
	panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var style:=StyleBoxFlat.new()
	style.bg_color=Color(0.03,0.08,0.12,0.88)
	style.border_color=Color("95d6ba")
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel",style)
	layer.add_child(panel)
	label(layer,title.get_slice("•",0),Vector2(28,20),13,"Title")
	label(layer,"",Vector2(760,20),13,"Hints")
	label(layer,"",Vector2(28,43),17,"Status")
	var message=label(layer,"",Vector2(24,592),16,"Message")
	message.size=Vector2(1104,48)
	message.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	var help=label(layer,"F1",Vector2(1104,20),12,"HelpHint")
	help.modulate.a=0.75
	return layer

static func camera(parent: Node,a: CoopPlayer,b: CoopPlayer,width: float) -> SharedCamera:
	var node:=Camera2D.new()
	node.name="SharedCamera"
	node.set_script(load("res://shared_camera.gd"))
	node.player_a_path=NodePath("../Players/"+a.name)
	node.player_b_path=NodePath("../Players/"+b.name)
	node.world_right=width
	node.world_bottom=648.0
	node.position=(a.position+b.position)*0.5
	parent.add_child(node)
	return node

static func branch(scene: String,path: String):
	var source=load(scene).instantiate()
	var node=source.get_node(path).duplicate()
	source.free()
	return node

static func safe_to_close(gate_node: CoopGate) -> bool:
	var shape=gate_node.get_node("CollisionShape2D")
	var bounds:=Rect2(shape.global_position-shape.shape.size*0.5,shape.shape.size).grow(8)
	for group in ["players","pushable"]:
		for actor in gate_node.get_tree().get_nodes_in_group(group):
			var col=actor.get_node_or_null("CollisionShape2D")
			if col!=null and col.shape is RectangleShape2D and Rect2(col.global_position-col.shape.size*0.5,col.shape.size).intersects(bounds): return false
	return true

static func clean_actor(actor: CoopPlayer) -> void:
	if actor.has_method("reset_after_recovery"): actor.call("reset_after_recovery")
	for property in ["_coyote_left","_jump_buffer_left","_landing_left","_interaction_left"]: actor.set(property,0.0)
	actor.velocity=Vector2.ZERO
	actor.animation_override=&""
	actor.movement_locked=false
	actor.animated_sprite.show()

static func controls(actor: CoopPlayer) -> String:
	return "A/D  Espaço/W  E  Q" if actor.player_id==1 else "Setas  Cima  Enter  Shift direito"

static func request_bridge_cancel(bridge: JakeBridge) -> void:
	if bridge.approach!=null and bridge.approach.active:
		bridge.approach.cancel()
		return
	if bridge.state==bridge.State.IDLE: return
	if bridge._bridge_active:
		bridge.set_meta("journey_cancel",true)
		if bridge.get_dependents().is_empty(): bridge._start_shrink()
	elif bridge.step==bridge.Step.SOURCE_EXTEND: bridge._start_source_retraction(true)
	elif bridge.step in [bridge.Step.GROW,bridge.Step.WAIT_RENDER]: bridge._start_shrink()

static func poll_bridge_cancel(bridge: JakeBridge) -> void:
	if bridge.state==bridge.State.IDLE:
		bridge.set_meta("journey_cancel",false)
	elif bridge.get_meta("journey_cancel",false) and bridge._bridge_active and bridge.get_dependents().is_empty(): bridge._start_shrink()

static func restore_restart_role(level: Node,property: String) -> void:
	var tree=level.get_tree()
	var config=tree.get_meta("journey_restart",{})
	if config.get("scene","")==level.scene_file_path:
		level.set(property,config.get("role",1))
		tree.remove_meta("journey_restart")

static func restart(level: Node,property: String) -> void:
	level.get_tree().set_meta("journey_restart",{"scene":level.scene_file_path,"role":level.get(property)})
	level.get_tree().reload_current_scene()

static func bridge_deck(permanent: PermanentBridge) -> void:
	permanent.get_node("Sprite2D").hide()
	var visual:=Node2D.new()
	visual.name="FullWidthDeck"
	visual.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	visual.set_script(load("res://journey_bridge_deck.gd"))
	permanent.add_child(visual)

static func sound(parent: Node,name: String) -> AudioStreamPlayer:
	var player:=AudioStreamPlayer.new()
	player.name=name+"Sound"
	player.stream=load("res://Assets/07_Audio/SFX/"+name+".wav")
	player.volume_db=-12.0
	parent.add_child(player)
	return player

static func style_button(button: Button) -> void:
	var style:=StyleBoxFlat.new()
	style.bg_color=Color("183642")
	style.border_color=Color("ffe69a")
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	button.add_theme_stylebox_override("normal",style)
	var hover:=style.duplicate()
	hover.bg_color=Color("365f69")
	button.add_theme_stylebox_override("hover",hover)
	button.add_theme_font_override("font",FONT)
	button.add_theme_font_size_override("font_size",16)

static func receiver_texture(path: String) -> Texture2D:
	var crop:=AtlasTexture.new()
	crop.atlas=load(path)
	crop.region=Rect2(0,0,64,48)
	return crop
