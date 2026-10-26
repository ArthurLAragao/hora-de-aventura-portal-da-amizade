extends Area2D
class_name FriendshipCrystal

signal collected

var is_collected := false
@onready var collect_sfx: AudioStreamPlayer2D = $CollectSFX

func _ready() -> void:
	add_to_group("friendship_crystal")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if is_collected or not body.is_in_group("players"):
		return
	is_collected = true
	collect_sfx.finished.connect(queue_free, CONNECT_ONE_SHOT)
	collect_sfx.play()
	collected.emit()
	$Sprite2D.hide()
	$CollisionShape2D.set_deferred("disabled", true)
	set_deferred("monitoring", false)
