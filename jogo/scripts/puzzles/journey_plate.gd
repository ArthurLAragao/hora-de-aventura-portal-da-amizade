extends "res://scripts/puzzles/pressure_plate.gd"
## Acabamento por ambiente; geometria de detecção e capacidades permanecem intactas.
@export var required_ability: StringName = &""
@export var visual_kind: StringName = &"step"
@export var completed:=false
@export var available:=true
var _last_visual:=""
var artwork: Sprite2D
var artwork_kind: StringName
## Filtra o corpo por tipo/capacidade conforme a regra da placa.
func _is_accepted(body: Node2D) -> bool:
	if required_ability!=&"": return body is CoopPlayer and body.has_ability(required_ability)
	return super._is_accepted(body)
## A textura acompanha a regra existente; o colisor e os sinais continuam no pai.
func _set_visual(pressed: bool) -> void:
	super._set_visual(pressed);plate_sprite.hide();z_index=1

## Troca o frame somente quando muda pressão, disponibilidade ou conclusão.
func _process(_dt: float) -> void:
	var art=preload("res://scripts/scenery/mechanism_sprite.gd")
	if artwork==null or artwork_kind!=visual_kind:
		if artwork!=null:artwork.queue_free()
		artwork=art.plate(self,art.phase(self),visual_kind in [&"reunion",&"confirm"]);artwork_kind=visual_kind
	var state:=visual_state()
	if state!=_last_visual:_last_visual=state;artwork.frame=art.state(is_active(),completed,available)
func visual_state() -> String:
	return "complete" if completed else "pressed" if is_active() else "available" if available else "inactive"
