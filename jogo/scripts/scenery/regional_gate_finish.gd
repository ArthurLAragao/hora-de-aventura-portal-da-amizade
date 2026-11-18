@tool
extends Node2D
## Native-size local art only. CoopGate remains the sole owner of collision/state.
const ART = "res://Assets/03_Objects_and_Puzzles/pixel_refinement/"
var gate: CoopGate
var region := 3
var box := Rect2()
var previous := false
var frame_sprite: Sprite2D
var leaf_sprite: Sprite2D
var opening: Tween
var leaf_origin:=Vector2.ZERO

## Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: folha e moldura dos portões regionais.
func _ready() -> void:
	gate=get_parent() as CoopGate
	var shape:=gate.get_node("CollisionShape2D") as CollisionShape2D
	var size: Vector2=shape.shape.size
	box=Rect2(shape.position-size*0.5,size)
	z_index=1
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	gate.get_node("Sprite2D").hide()
	var theme:="cave" if region==3 else "candy"
	var height:=str(int(size.y))
	leaf_sprite=_sprite(theme+"_leaf_"+height+".png",box.position)
	frame_sprite=_sprite(theme+"_frame_"+height+".png",box.position-Vector2(8,12))
	leaf_origin=leaf_sprite.position
	_sync()

## Cria o sprite local mantendo sua escala nativa e referência de textura.
func _sprite(file: String,at: Vector2) -> Sprite2D:
	var sprite:=Sprite2D.new()
	sprite.texture=load(("res://Assets/02_Environments/manual_review/" if file.contains("256") else ART)+file)
	sprite.centered=false
	sprite.position=at
	add_child(sprite)
	return sprite

## Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: folha e moldura dos portões regionais.
func _process(_delta: float) -> void:
	if is_instance_valid(gate) and previous!=gate.is_open:_sync()

## Sincroniza a folha visível com o estado do portão.
func _sync() -> void:
	previous=gate.is_open
	if opening:opening.kill()
	leaf_sprite.position=leaf_origin;leaf_sprite.modulate.a=1.0;leaf_sprite.show()
	if previous:
		# A folha recua brevemente; o estado e a colisão continuam pertencendo a CoopGate.
		opening=create_tween().set_parallel(true)
		opening.tween_property(leaf_sprite,"position:y",leaf_origin.y-16.0,0.28).set_trans(Tween.TRANS_SINE)
		opening.tween_property(leaf_sprite,"modulate:a",0.0,0.28)
		opening.chain().tween_callback(leaf_sprite.hide)
