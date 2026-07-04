extends PlayerState

func enter():
	player.crouch_collider()

func exit():
	player.uncrouch_collider()


func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.apply_horizontal_movement()

	

	if player.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		return

	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to(PlayerState.JUMP)
		return

	if player.is_falling():
		state_machine.transition_to(PlayerState.FALL)
		return

	if Input.is_action_just_released("down"):
		state_machine.transition_to(PlayerState.IDLE)
		return


	player.animate("Crouch")

	player.move_and_slide()
