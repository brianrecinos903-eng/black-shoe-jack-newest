extends Area2D
class_name WerefishBiscuit

## Placeholder pickup for the werefish transformation.
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("set_werefish_state"):
		body.set_werefish_state(true)
		queue_free()
