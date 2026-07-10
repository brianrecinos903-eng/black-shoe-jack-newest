extends Area2D

@export var jump_pad_force: float = 900



func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.velocity.y = -jump_pad_force
