extends Node2D
## Two physical conduit pieces: align shapes, then let BMO connect the battery.
var turns: Array[int]=[1,1]
var areas: Array[Area2D]=[]
var indicators: Array[Label]=[]
var locked:=false
var root_level: Node2D
func _ready() -> void:
	root_level=get_parent()
	for i in 2:
		var area:=Area2D.new();area.position=Vector2(1432+i*88,354);area.collision_layer=0;area.collision_mask=2
		var shape:=CollisionShape2D.new();var rect:=RectangleShape2D.new();rect.size=Vector2(68,70);shape.shape=rect;area.add_child(shape)
		var prompt:=Label.new();prompt.position=Vector2(-36,-70);prompt.add_theme_font_size_override("font_size",14)
		prompt.add_theme_constant_override("outline_size",3);area.add_child(prompt);indicators.append(prompt)
		add_child(area);areas.append(area)
	queue_redraw()
func solved() -> bool:return turns==[0,0]
func _process(_delta: float) -> void:
	for i in 2:
		indicators[i].text=""
		if locked:continue
		for actor in [root_level.finn,root_level.bmo]:
			if not actor.has_ability(&"lever") or actor.movement_locked or not areas[i].overlaps_body(actor):continue
			indicators[i].text=("E" if actor.player_id==1 else "Enter")+": girar conexão"
			if Input.is_action_just_pressed(actor.get_interact_action()):
				turns[i]=1-turns[i];queue_redraw()
	if root_level.energy_terminal.energized:locked=true
func _draw() -> void:
	# Matching ends are horizontal: no hidden sequence or reliance on color.
	for i in 2:
		var p:=Vector2(1432+i*88,354)
		draw_rect(Rect2(p-Vector2(24,27),Vector2(48,61)),Color("573b55"))
		draw_rect(Rect2(p-Vector2(21,24),Vector2(42,55)),Color("99745f"))
		if turns[i]==0:
			draw_rect(Rect2(p-Vector2(27,6),Vector2(54,12)),Color("395c54"))
			draw_rect(Rect2(p-Vector2(25,4),Vector2(50,5)),Color("9ecab0"))
		else:
			draw_rect(Rect2(p-Vector2(6,22),Vector2(12,44)),Color("395c54"))
			draw_rect(Rect2(p-Vector2(4,20),Vector2(5,40)),Color("9ecab0"))
		draw_circle(p,3,Color("efce9b"))
	for x in [1384,1464,1552]:
		draw_rect(Rect2(x,349,22,10),Color("395c54"))
		draw_rect(Rect2(x,351,22,4),Color("9ecab0"))
