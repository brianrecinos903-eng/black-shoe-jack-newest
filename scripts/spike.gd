extends Area2D

var spike_velocityY_change = -750

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
			body.take_dmg(1)
			body.velocity.y = spike_velocityY_change
