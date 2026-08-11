extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	anim.play("idle")

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.take_dmg(1, Helpers.DamageType.TRAP)
		queue_free()
