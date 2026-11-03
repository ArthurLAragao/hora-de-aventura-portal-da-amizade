extends Node
## Retira a camada de tutorial das fases; não altera texto, visibilidade lógica ou regras dos mecanismos.
var level: Node

## Observa elementos criados pelos construtores e configura os controles já existentes.
func _ready() -> void:
	level=get_parent()
	get_tree().node_added.connect(on_node_added)
	scan.call_deferred(level)

## Percorre uma vez a cena pronta, incluindo os elementos montados em execução.
func scan(parent: Node) -> void:
	apply(parent)
	for child in parent.get_children():scan(child)

## Trata somente novos controles desta fase, após sua hierarquia estar disponível.
func on_node_added(node: Node) -> void:
	if node is Control and level.is_ancestor_of(node):apply.call_deferred(node)

## Preserva conversas, celebração, pistas e interfaces abertas voluntariamente.
func protected(node: Node) -> bool:
	var ancestor:=node.get_parent()
	while ancestor!=null and ancestor!=level:
		if ancestor.name in [&"FriendshipStory",&"Celebration",&"MusicalClue",&"Clue"] or ancestor is PanelContainer:return true
		ancestor=ancestor.get_parent()
	return node.name==&"Help" or (node is Label and node.text in ["◇","○","△","□"])

## Desativa apenas o desenho dos textos externos e fundos de tutorial, sem disputar updates de gameplay.
func apply(node: Node) -> void:
	if not is_instance_valid(node) or not node is CanvasItem or not level.is_ancestor_of(node):return
	if protected(node):return
	var header_background: bool=node is Panel and node.get_parent().name in [&"HUD",&"Instructions"]
	if node is Label or header_background:
		# O culling permanece mesmo quando um mecanismo atualiza text/visible.
		node.visibility_layer=0
		node.set_meta("tutorial_hidden",true)

## Desconecta o observador ao trocar de cena, sem deixar callbacks de uma fase anterior.
func _exit_tree() -> void:
	if get_tree()!=null and get_tree().node_added.is_connected(on_node_added):get_tree().node_added.disconnect(on_node_added)
