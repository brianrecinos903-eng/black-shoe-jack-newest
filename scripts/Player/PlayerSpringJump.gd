extends PlayerState

var ignore_floor_check := true


func enter():
	ignore_floor_check = true
	player.velocity.x = player.face_direction * player.spring_jump_velocity.x
	player.velocity.y = player.spring_jump_velocity.y


func physics_update(delta: float) -> void:
	player.apply_jump(delta)
	player.apply_speed_input()

	if player.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		return

	if Input.is_action_just_pressed("down"):
		state_machine.transition_to(PlayerState.SLAM)
		return


	if Input.is_action_just_released("jump"):
		state_machine.transition_to(PlayerState.FALL)
		return
	
	if abs(player.velocity.x) <= 300:
		player.apply_horizontal_movement()


	if abs(player.velocity.x) <= 100 and not ignore_floor_check and player.is_on_floor():
		var next_state := player.grounded_state_name()
		state_machine.transition_to(next_state)
		player.animate(next_state)
		player.move_and_slide()
		return

	player.velocity.x = move_toward(player.velocity.x, 0, player.spring_jump_velocity.x * delta)

	player.animate("Jump")
	player.move_and_slide()
	ignore_floor_check = false
