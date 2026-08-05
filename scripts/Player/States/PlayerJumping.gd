extends PlayerState

var ignore_floor_check := true


func _ready() -> void:
	state_name = PlayerState.JUMP


func enter():
	if not state_owner.in_water:
		state_owner.gravity_factor = state_owner.jump_gravity_factor
		if state_machine.previous_state == PlayerState.WALL_RUN:
			state_owner.velocity.y = -state_owner.jump_impulse
			state_owner.velocity.x = -state_owner.move_direction * state_owner.wall_jump_impulse
		elif state_machine.previous_state == PlayerState.CEILLING_RUN:
			state_owner.velocity.y = state_owner.ceilling_jump_impulse
		else:
			state_owner.velocity.y = -state_owner.jump_impulse
		ignore_floor_check = true
	else:
		state_owner.velocity.y = -state_owner.swim_up_impulse
		state_owner.gravity_factor = state_owner.water_gravity_factor
		state_owner.can_coyote = true


func exit():
	if state_owner.in_water:
		state_owner.gravity_factor = state_owner.water_gravity_factor


func physics_update(delta: float) -> void:
	state_owner.apply_speed_input()
	state_owner.apply_motion(delta)
	state_owner.move_and_slide()
	state_owner.apply_gravity(delta)
	if not state_owner.in_water:
		if Input.is_action_just_released("jump") and state_owner.velocity.y < -state_owner.min_jump_impulse:
			state_owner.velocity.y = -state_owner.min_jump_impulse

		if state_owner.velocity.y >= 150:
			state_machine.transition_to(PlayerState.FALL)
			return
		if (
			state_machine.previous_state == PlayerState.CEILLING_RUN
			or state_machine.previous_state == PlayerState.WALL_RUN
			or state_machine.previous_state == PlayerState.HURT
		):
			state_owner.can_coyote = true
			state_machine.transition_to(PlayerState.FALL)
			return
		if state_machine.previous_state == PlayerState.FALL:
			if state_owner.is_on_ceiling() and state_owner.move_direction != 0:
				state_machine.transition_to(PlayerState.CEILLING_RUN)
				return
		if Input.is_action_just_pressed("down"):
			state_owner.can_coyote = true
			state_machine.transition_to(PlayerState.SLAM)
			return
		if state_owner.speed_multiplier >= 1.5:
			if state_owner.is_on_wall():
				state_machine.transition_to(PlayerState.WALL_RUN)
				return
		if not ignore_floor_check and state_owner.is_on_floor():
			state_owner.can_coyote = true
			state_machine.transition_to(state_owner.grounded_state_name())
			return
	else:
		state_owner.apply_water_drag(delta)
		print("swimming up")
		if Input.is_action_just_pressed("up"):
			state_owner.velocity.y = -state_owner.swim_up_impulse

		if Input.is_action_just_released("up"):
			state_machine.transition_to(state_owner.grounded_state_name())
			return

		if not ignore_floor_check and state_owner.is_on_floor():
			state_owner.can_coyote = true
			state_machine.transition_to(state_owner.grounded_state_name())
			return
	if state_owner.is_hurt:
		state_owner.can_coyote = true
		state_machine.transition_to(PlayerState.HURT)
		return
	# TODO: Make animation for swim up
	state_owner.anim.play("jump")
	ignore_floor_check = false
