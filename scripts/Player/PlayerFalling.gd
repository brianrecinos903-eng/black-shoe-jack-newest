extends PlayerState


var ignore_floor_check := true

func enter():
	ignore_floor_check = true

func physics_update(delta):
	player.apply_fall(delta)
	player.apply_horizontal_movement()
	player.apply_speed_input()


	Helpers.wait(player.coyote_time)
	if Input.is_action_just_pressed("jump") and player.can_coyote:
		player.can_coyote = false
		state_machine.transition_to(PlayerState.JUMP)
		return


	if Input.is_action_just_pressed("down"):
		state_machine.transition_to(PlayerState.SLAM)
		return
		
	if player.is_on_ceiling() and player.direction != 0:
		state_machine.transition_to(PlayerState.CEILLING_RUN)
		return
	
	if player.speed_mult >= 1.5:
		if player.is_on_wall():
			state_machine.transition_to(PlayerState.WALL_RUN)
			return

	if not ignore_floor_check and player.is_on_floor():
		state_machine.transition_to(player.grounded_state_name())
		player.can_coyote = true
		return

	player.animate("Jump")
	player.move_and_slide()
	ignore_floor_check = false
