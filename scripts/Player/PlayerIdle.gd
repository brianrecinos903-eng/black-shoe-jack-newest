extends PlayerState
	

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.apply_horizontal_movement()
	player.apply_speed_input()


	if Input.is_action_just_pressed("jump"):
		player.velocity.y = player.jump_velocity
		state_machine.transition_to("Jump")
		return

	if player.is_falling():
		state_machine.transition_to("Fall")
		return

	if player.direction != 0:
		state_machine.transition_to("Move")
		return

	player.animate("Idle")
	player.move_and_slide()
