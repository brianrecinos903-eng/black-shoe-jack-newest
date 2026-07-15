extends PlayerState


func _ready() -> void:
	state_name = PlayerState.MOVE

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.apply_motion(delta)
	player.apply_speed_input()

	if not player.in_water:
		if Input.is_action_pressed("down") and not player.is_falling():
			state_machine.transition_to(PlayerState.SLIDE)
			return

		if player.is_falling():
			state_machine.transition_to(PlayerState.FALL)
			return

		if player.speed_multiplier >= 1.5:
			if player.is_on_wall():
				state_machine.transition_to(PlayerState.WALL_RUN)
				return

	if player.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		return

	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to(PlayerState.JUMP)
		return

	if player.move_direction == 0:
		state_machine.transition_to(PlayerState.IDLE)
		return


	player.anim_move()
	player.move_and_slide()
