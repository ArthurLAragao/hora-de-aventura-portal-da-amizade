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
	if root_level.energy_terminal.energized and not locked:
		locked=true;queue_redraw()
func _draw() -> void:
	# Copper housings sit on frosting-capped plinths; shaped contacts show alignment.
	var outline:=Color("583849")
	var copper:=Color("ae795c")
	var edge:=Color("edc78c")
	var pipe:=Color("699c83")
	for i in 2:
		var p:=Vector2(1432+i*88,354)
		draw_rect(Rect2(p-Vector2(27,28),Vector2(54,62)),outline)
		draw_rect(Rect2(p-Vector2(24,25),Vector2(48,57)),copper)
		draw_rect(Rect2(p-Vector2(23,24),Vector2(2,54)),edge)
		draw_rect(Rect2(p+Vector2(20,-23),Vector2(3,53)),Color("83554d"))
		draw_rect(Rect2(p+Vector2(-28,28),Vector2(56,6)),outline)
		draw_rect(Rect2(p+Vector2(-26,27),Vector2(52,3)),Color("fae2b0"))
		for xy in [Vector2(-19,-19),Vector2(17,-19),Vector2(-19,21),Vector2(17,21)]:
			draw_rect(Rect2(p+xy,Vector2(3,3)),outline)
			draw_rect(Rect2(p+xy,Vector2(2,1)),edge)
		var aligned:=turns[i]==0
		var channel:=Rect2(p-Vector2(27,7),Vector2(54,14)) if aligned else Rect2(p-Vector2(7,22),Vector2(14,44))
		draw_rect(channel,outline)
		channel=channel.grow(-2);draw_rect(channel,pipe)
		if aligned:
			draw_rect(Rect2(p-Vector2(24,4),Vector2(48,3)),Color("bed4ad"))
			for x in [-23,18]:draw_rect(Rect2(p+Vector2(x,-8),Vector2(5,16)),edge)
		else:
			draw_rect(Rect2(p-Vector2(4,19),Vector2(3,38)),Color("bed4ad"))
			for y in [-20,15]:draw_rect(Rect2(p+Vector2(-8,y),Vector2(16,5)),edge)
		draw_rect(Rect2(p-Vector2(5,5),Vector2(10,10)),outline)
		draw_rect(Rect2(p-Vector2(3,3),Vector2(6,6)),Color("e4f0bd") if locked else edge)
		draw_rect(Rect2(p-Vector2(1,2),Vector2(2,4)),outline)
	for x in [1384,1464,1552]:
		draw_rect(Rect2(x,348,22,12),outline)
		draw_rect(Rect2(x,350,22,8),pipe)
		draw_rect(Rect2(x,351,22,2),Color("bed4ad"))
