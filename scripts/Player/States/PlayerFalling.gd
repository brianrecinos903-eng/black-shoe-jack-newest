extends PlayerState


func _ready() -> void:
	state_name = PlayerState.FALL


var ignore_floor_check := true


func enter():
	ignore_floor_check = true
	if not state_owner.in_water:
		state_owner.gravity_factor = state_owner.fall_gravity_factor
	else:
		state_owner.can_coyote = true
		state_owner.gravity_factor = state_owner.water_gravity_factor


func exit():
	if state_owner.in_water:
		state_owner.gravity_factor = state_owner.water_gravity_factor
	else:
		state_owner.gravity_factor = state_owner.default_gravity_factor


func physics_update(delta):
	state_owner.apply_gravity(delta)
	state_owner.apply_motion(delta)
	state_owner.apply_speed_input()
	Helpers.wait(state_owner.coyote_timeframe)
	if state_owner.in_water:
		state_owner.apply_water_drag(delta)
		if Input.is_action_just_pressed("up"):
			state_machine.transition_to(PlayerState.JUMP)
			return
		if not ignore_floor_check and state_owner.is_on_floor():
			state_owner.can_coyote = true
			state_machine.transition_to(state_owner.grounded_state_name())
			return
		state_owner.anim.play("jump")
		state_owner.move_and_slide()
		ignore_floor_check = false
		return
	if Input.is_action_just_pressed("jump") and state_owner.can_coyote:
		state_owner.can_coyote = false
		state_machine.transition_to(PlayerState.JUMP)
		return
	if not state_owner.in_water:
		if Input.is_action_pressed("down"):
			state_machine.transition_to(PlayerState.SLAM)
			return

	if state_owner.speed_multiplier >= 1.5:
		if state_owner.is_on_wall():
			state_machine.transition_to(PlayerState.WALL_RUN)
			return
	if not ignore_floor_check and state_owner.is_on_floor():
		state_machine.transition_to(state_owner.grounded_state_name())
		state_owner.can_coyote = true
		return
	state_owner.anim.play("jump")
	state_owner.move_and_slide()
	ignore_floor_check = false
