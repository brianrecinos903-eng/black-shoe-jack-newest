extends PlayerState

@export var button_hold_time = 0.5


func handle_bounce() -> void:
	if player.bounces_left == 0:
		var next_state := player.grounded_state_name()
		state_machine.transition_to(next_state)
		player.animate(next_state)
		player.move_and_slide()
		return
	elif player.bounces_left > 0:
		player.velocity.y = player.jump_velocity
		player.bounces_left -= 1


func handle_key_hold() -> void:
	if not Input.is_action_pressed("down"):
		handle_bounce()
		return
	await get_tree().create_timer(0.5).timeout
	if not Input.is_action_pressed("down"):
		return

	player.velocity.y = player.uber_jump_velocity
	state_machine.transition_to("Jump")



func enter() -> void:
	player.speed_mult = 0.2
	player.bounces_left = player.max_bounces

func physics_update(delta: float) -> void:
	player.apply_fall(delta)
	player.apply_horizontal_movement()

	if player.is_on_floor():
		handle_key_hold()
		

	player.animate("Slam")
	player.move_and_slide()
