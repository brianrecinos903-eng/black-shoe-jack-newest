extends PlayerState

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.apply_horizontal_movement()
	player.apply_speed_input()

	if Input.is_action_just_pressed("down"):
		state_machine.transition_to("Slam")
		return

	if player.is_on_floor():
		state_machine.transition_to(player.grounded_state_name())
		return

	player.animate("Jump")
	player.move_and_slide()
