extends enemy


func _on_skip_move_timer_timeout() -> void:
	stunned = false


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") && !stunned:
		body.take_dmg(atk_damage)
