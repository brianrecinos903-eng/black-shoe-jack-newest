extends Area2D

signal player_entered_spike

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_entered_spike.emit()
