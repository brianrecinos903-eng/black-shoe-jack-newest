extends PlayerState

func enter():
	player.gravity_scale = -1
	
func exit():
	player.gravity_scale = 1
 

func physics_update(delta: float) -> void:
	player.apply_horizontal_movement()
	player.apply_speed_input()

	player.velocity.y = -100
	if player.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		return

	# if Input.is_action_just_pressed("jump"):
	# 	# player.velocity.x = player.get_normal * player.jump_velocity
	# 	state_machine.transition_to(PlayerState.JUMP)
	# 	return

	# if Input.is_action_pressed("down"):
	# 	state_machine.transition_to(PlayerState.SLAM)
	# 	return


	if not player.is_level_within_distance(Vector2.UP, 70) or Input.is_action_just_pressed("jump"):
		print("Player not on ceilling")
		player.velocity.y = -200
		state_machine.transition_to(PlayerState.FALL)
		return

	player.animate("Move")
	player.move_and_slide()
