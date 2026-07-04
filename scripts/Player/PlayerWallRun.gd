extends PlayerState


func enter():
	player.gravity_scale = 0
	player.velocity.y = -abs(player.velocity.x)
	print("wall run dimension ", player.direction)
	
func exit():
	player.velocity.x = player.direction * abs(player.velocity.y)
	print("player velocity x: ", player.velocity.x)
	player.gravity_scale = 1


func physics_update(delta: float) -> void:
	player.apply_wallrun()
	player.apply_speed_input()
	print("wall run dimension ", player.direction)

	if player.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		return

	if Input.is_action_just_pressed("jump"):
		player.velocity.x = player.get_wall_normal().x * player.jump_velocity
		state_machine.transition_to(PlayerState.JUMP)
		return

	if Input.is_action_pressed("down"):
		state_machine.transition_to(PlayerState.SLAM)
		return

	if player.is_falling():
		state_machine.transition_to(PlayerState.FALL)
		return

	if not player.is_on_wall():
		state_machine.transition_to(player.grounded_state_name())
		return

	player.animate("Move")
	player.move_and_slide()
