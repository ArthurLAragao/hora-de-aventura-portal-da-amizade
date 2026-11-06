extends Node
## Aplica apenas as duas revisões locais pedidas: portões da Fase 1 e placas da Fase 6.
@export_range(1,6) var phase:=1

## Aguarda a construção dos mecanismos pela raiz da fase.
func _ready() -> void:
	apply.call_deferred()

## Não altera scripts compartilhados nem a geometria de detecção dos mecanismos.
func apply() -> void:
	for node in get_parent().get_children():
		if (phase==1 and node is CoopGate) or (phase==6 and node is PressurePlate):
			var finish:=Node2D.new();finish.name="LocalFinish"
			finish.set_script(load("res://scripts/scenery/forest_gate_finish.gd" if phase==1 else "res://scripts/scenery/sanctuary_plate_finish.gd"))
			node.add_child(finish)
