extends PlayerState

var ignore_floor_check := true


func enter():
	player.velocity.y = player.jump_velocity
	ignore_floor_check = true


func physics_update(delta: float) -> void:
	player.apply_jump(delta)
	player.apply_horizontal_movement()
	player.apply_speed_input()

	if player.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		player.can_coyote = true
		return

	if Input.is_action_just_pressed("down"):
		state_machine.transition_to(PlayerState.SLAM)
		player.can_coyote = true
		return

	if Input.is_action_just_released("jump"):
		state_machine.transition_to(PlayerState.FALL)
		return

	if not ignore_floor_check and player.is_on_floor():
		state_machine.transition_to(player.grounded_state_name())
		player.can_coyote = true
		return

	player.animate("Jump")
	player.move_and_slide()
	ignore_floor_check = false
