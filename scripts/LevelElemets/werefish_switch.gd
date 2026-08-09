extends Area2D
class_name WerefishSwitch

## Placeholder switch. Stand in its trigger and press the interact action to
## return the player to their normal form.
var player_in_range: Node2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range == null or not event.is_action_pressed("interact") or event.is_echo():
		return
	if player_in_range.has_method("set_werefish_state"):
		player_in_range.set_werefish_state(false)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = body

func _on_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null
