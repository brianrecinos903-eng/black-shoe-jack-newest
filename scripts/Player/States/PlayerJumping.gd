extends PlayerState

var ignore_floor_check := true

func _ready() -> void:
	state_name = PlayerState.JUMP

func enter():
	player.gravity_factor = player.jump_gravity_factor
	if state_machine.previous_state == PlayerState.WALL_RUN:
		player.velocity.y = player.jump_power
		player.velocity.x = -player.move_direction * player.walljump_power
	elif state_machine.previous_state == PlayerState.CEILLING_RUN:
		player.velocity.y = -200
	else:
		player.velocity.y = player.jump_power

	ignore_floor_check = true


func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.apply_speed_input()
	if abs(player.velocity.x) <= 500:
		player.apply_horizontal_movement()

	match state_machine.previous_state:
		PlayerState.CEILLING_RUN, PlayerState.WALL_RUN, PlayerState.HURT:
			state_machine.transition_to(PlayerState.FALL)
			player.can_coyote = true 
			return

	if player.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		player.can_coyote = true
		return

	if Input.is_action_just_pressed("down"):
		state_machine.transition_to(PlayerState.SLAM)
		player.can_coyote = true
		return

	if player.velocity.y >= 150:
		state_machine.transition_to(PlayerState.FALL)
		return

	if player.acceleration >= 1.5:
		if player.is_on_wall():
			state_machine.transition_to(PlayerState.WALL_RUN)
			return


	if not ignore_floor_check and player.is_on_floor():
		state_machine.transition_to(player.grounded_state_name())
		player.can_coyote = true
		return

	player.anim.play("jump")
	player.move_and_slide()
	ignore_floor_check = false
