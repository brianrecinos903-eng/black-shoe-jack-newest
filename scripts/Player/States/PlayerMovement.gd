extends PlayerState


func _ready() -> void:
	state_name = PlayerState.MOVE


func enter():
	if state_owner.in_water:
		state_owner.gravity_factor = state_owner.water_gravity_factor


func exit():
	if state_owner.in_water:
		state_owner.gravity_factor = state_owner.water_gravity_factor


func physics_update(delta: float) -> void:
	state_owner.apply_motion(delta)
	state_owner.apply_speed_input()
	state_owner.apply_gravity(delta)
	if not state_owner.in_water:
		if Input.is_action_pressed("down") and not state_owner.is_falling():
			state_machine.transition_to(PlayerState.SLIDE)
			return
		if state_owner.is_falling():
			state_machine.transition_to(PlayerState.FALL)
			return
		if state_owner.speed_multiplier >= 1.5:
			if state_owner.is_on_wall():
				state_machine.transition_to(PlayerState.WALL_RUN)
				return
		if Input.is_action_pressed("jump"):
			state_machine.transition_to(PlayerState.JUMP)
			return
	else:
		if Input.is_action_pressed("up"):
			state_machine.transition_to(PlayerState.JUMP)
			return
	if state_owner.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		return
	if state_owner.move_direction == 0:
		state_machine.transition_to(PlayerState.IDLE)
		return
	if state_owner.in_water:
		state_owner.apply_water_drag(delta)
		if Input.is_action_pressed("down"):
			state_machine.transition_to(PlayerState.CROUCH)
			return
	state_owner.anim_move()
	state_owner.move_and_slide()
