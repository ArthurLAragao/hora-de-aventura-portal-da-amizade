extends "res://tests/journey_driver.gd"

func run() -> void:
	root.size=viewport_size
	for number in [2,3,4]:
		if is_instance_valid(level):
			stop_test_audio(level);level.queue_free();await frames(4)
		level=load("res://level_%d.tscn"%number).instantiate()
		root.add_child(level);current_scene=level
		await frames(30)
		check("region %d decorations contain no physics"%number,count_physics(level.get_node("RegionalScenery"))==0)
		await capture("finish-%d-closed-%d"%[number,viewport_size.x])
		if number in [3,4]:
			for gate in level.find_children("*","StaticBody2D",true,false):
				if not gate is CoopGate:continue
				check("gate has local art and original hidden",gate.has_node("RegionalFinish") and not gate.get_node("Sprite2D").visible)
				var art=gate.get_node("RegionalFinish")
				check("art closed leaf matches exact existing collider",art.box.size==gate.get_node("CollisionShape2D").shape.size)
				gate.open_gate()
			await frames(5)
			await capture("finish-%d-open-%d"%[number,viewport_size.x])
			for gate in level.find_children("*","StaticBody2D",true,false):
				if gate is CoopGate:check("open visuals follow same gate state",gate.get_node("RegionalFinish").previous and gate.get_node("CollisionShape2D").disabled)
	await finish("Regional finish visual fixtures (not route evidence)")

func count_physics(node: Node) -> int:
	var total:=1 if node is CollisionObject2D else 0
	for child in node.get_children():total+=count_physics(child)
	return total
