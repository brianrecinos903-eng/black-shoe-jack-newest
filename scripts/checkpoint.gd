extends Area2D

@onready var pos_mark: Node2D = $PosMark


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.last_checkpoint = pos_mark.global_position
