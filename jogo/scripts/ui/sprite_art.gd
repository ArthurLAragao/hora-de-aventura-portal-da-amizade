extends RefCounted
## Recursos de apresentação prontos: nenhuma imagem é desenhada ou recortada em execução.
const ROOT="res://Assets/04_Interface/Sprites_Final/"
const MONUMENTS=["monument_forest","monument_ice","monument_music","monument_workshop","monument_mirror","monument_friendship"]
const GEM_Y=[-64,-74,-69,-66,-79,-66]
const COLORS=[Color("79d9ef"),Color("87ddaa"),Color("c497f1"),Color("f4b47d"),Color("f0a8ce"),Color("ead281")]
static var spin: SpriteFrames
static var activation: SpriteFrames

## Fatias do atlas importado; recursos compartilhados e imutáveis entre as instâncias.
static func frames(burst:=false) -> SpriteFrames:
	if burst and activation!=null:return activation
	if not burst and spin!=null:return spin
	var result:=SpriteFrames.new();result.remove_animation(&"default")
	var clip: StringName=&"activate" if burst else &"spin"
	var cell:=Vector2(48,48) if burst else Vector2(32,40)
	result.add_animation(clip);result.set_animation_speed(clip,12 if burst else 7);result.set_animation_loop(clip,not burst)
	var sheet: Texture2D=load(ROOT+("activation_strip.png" if burst else "crystal_spin.png"))
	for i in 8:
		var frame:=AtlasTexture.new();frame.atlas=sheet;frame.region=Rect2(Vector2(i*cell.x,0),cell);result.add_frame(clip,frame)
	if burst:activation=result
	else:spin=result
	return result

## O cristal muda de facetas pelos oito frames reais, sem deformar sua largura.
static func gem(parent: Node,at: Vector2,color: Color,factor:=1.0) -> AnimatedSprite2D:
	var node:=AnimatedSprite2D.new();node.sprite_frames=frames();node.position=at;node.modulate=color
	node.scale=Vector2.ONE*factor;node.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;parent.add_child(node);node.play(&"spin");return node

## Um efeito finito, com oito sprites; o último quadro não deixa resíduos na tela.
static func burst(parent: Node,at: Vector2,color: Color,factor:=1.0) -> AnimatedSprite2D:
	var node:=AnimatedSprite2D.new();node.sprite_frames=frames(true);node.position=at;node.modulate=color
	node.scale=Vector2.ONE*factor;node.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;parent.add_child(node)
	node.animation_finished.connect(node.hide);return node

## Nove recortes preservam os cantos do PNG ao adaptar a caixa ao texto e à resolução.
static func skin(dialogue:=false,tint:=Color.WHITE) -> StyleBoxTexture:
	var style:=StyleBoxTexture.new();style.texture=load(ROOT+("dialogue_frame.png" if dialogue else "button_frame.png"));style.modulate_color=tint
	for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
		style.set_texture_margin(side,20 if dialogue else 8)
		style.set_content_margin(side,20 if dialogue else 7)
	return style

## Estados mantêm a mesma textura; brilho e profundidade indicam foco e pressão.
static func button(node: Button) -> void:
	node.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	for state in ["normal","hover","pressed","focus","disabled"]:
		var tint:=Color("dbecdf") if state=="normal" else Color("fff0b0") if state in ["focus","hover"] else Color("7cabb0") if state=="pressed" else Color("657878")
		node.add_theme_stylebox_override(state,skin(false,tint))
