extends PlayerState

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.apply_horizontal_movement()
	player.apply_speed_input()

	if player.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		return

	if Input.is_action_just_pressed("jump"):
		player.velocity.y = player.jump_velocity
		state_machine.transition_to(PlayerState.JUMP)
		return

	if player.is_falling():
		state_machine.transition_to(PlayerState.FALL)
		return

	if player.direction == 0:
		state_machine.transition_to(PlayerState.IDLE)
		return

	player.animate("Move")
	player.move_and_slide()
