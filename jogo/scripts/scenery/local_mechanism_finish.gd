extends Node
## Aplica os acabamentos locais, inclusive ao portão final aninhado da trilha.
@export_range(1,6) var phase:=1
func _ready() -> void:apply.call_deferred()
func collect(parent: Node,result: Array) -> void:
	for child in parent.get_children():
		if (phase==1 and child is CoopGate) or (phase==6 and child is PressurePlate):result.append(child)
		collect(child,result)
func apply() -> void:
	var lever=get_parent().get_node_or_null("Lever")
	if phase==1 and lever!=null and not lever.has_node("LeverArtwork"):
		var skin:=Node2D.new();skin.name="LeverArtwork";skin.set_script(load("res://scripts/scenery/forest_lever_skin.gd"));lever.add_child(skin)
	var candidates: Array=[];collect(get_parent(),candidates)
	for node in candidates:
		if node.has_node("LocalFinish"):continue
		var finish:=Node2D.new();finish.name="LocalFinish";finish.set_script(load("res://scripts/scenery/forest_gate_finish.gd" if phase==1 else "res://scripts/scenery/sanctuary_plate_finish.gd"));node.add_child(finish)
