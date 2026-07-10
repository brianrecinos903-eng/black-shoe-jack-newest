extends PlayerState

var ignore_floor_check := true

func _ready() -> void:
	state_name = PlayerState.JUMP

func enter():
	player.gravity_factor = player.jump_gravity_factor
	if state_machine.previous_state == PlayerState.WALL_RUN:
		player.velocity.y = player.jump_impulse
		player.velocity.x = -player.move_direction * player.wall_jump_impulse
	elif state_machine.previous_state == PlayerState.CEILLING_RUN:
		player.velocity.y = 200
	else:
		player.velocity.y = player.jump_impulse

	ignore_floor_check = true


func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.apply_speed_input()
	player.apply_horizontal_movement(delta)

	if state_machine.previous_state == PlayerState.CEILLING_RUN or state_machine.previous_state ==  PlayerState.WALL_RUN or state_machine.previous_state == PlayerState.HURT:
		player.can_coyote = true 
		state_machine.transition_to(PlayerState.FALL)
		return

	if state_machine.previous_state == PlayerState.FALL:
		if player.is_on_ceiling() and player.move_direction != 0:
			state_machine.transition_to(PlayerState.CEILLING_RUN)
			return

	if player.is_hurt:
		player.can_coyote = true
		state_machine.transition_to(PlayerState.HURT)
		return

	if Input.is_action_just_pressed("down"):
		player.can_coyote = true
		state_machine.transition_to(PlayerState.SLAM)
		return

	if player.velocity.y >= 150:
		state_machine.transition_to(PlayerState.FALL)
		return

	if player.speed_multiplier >= 1.5:
		if player.is_on_wall():
			state_machine.transition_to(PlayerState.WALL_RUN)
			return


	if not ignore_floor_check and player.is_on_floor():
		player.can_coyote = true
		state_machine.transition_to(player.grounded_state_name())
		return

	player.anim.play("jump")
	player.move_and_slide()
	ignore_floor_check = false
