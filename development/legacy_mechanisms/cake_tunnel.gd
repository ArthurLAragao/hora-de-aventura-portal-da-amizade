extends Node2D
@onready var left: Area2D = $LeftEntry
@onready var right: Area2D = $RightEntry
@onready var prompt: Label = $Prompt
var status_message := ""

func can_interact(actor: CoopPlayer) -> bool:
	return is_instance_valid(actor) and actor.has_ability(&"crawl") and actor.has_method("begin_crawl") and (left.overlaps_body(actor) or right.overlaps_body(actor)) and actor.is_on_floor() and not actor.movement_locked

func interact(actor: CoopPlayer) -> bool:
	if not can_interact(actor): return false
	return bool(actor.call("begin_crawl",self))

func update_prompt(actor: CoopPlayer) -> void:
	if actor.get("crawling"):
		prompt.text = "Rasteje com esquerda/direita. Esc tenta levantar em local livre."
	elif can_interact(actor): prompt.text = ("E" if actor.player_id==1 else "Enter")+": entrar rastejando"
	else: prompt.text = "TÚNEL · somente Cake · altura livre: 22,35"
