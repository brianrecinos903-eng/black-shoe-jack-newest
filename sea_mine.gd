extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.take_dmg(1, Helpers.DamageType.TRAP)
		queue_free()
