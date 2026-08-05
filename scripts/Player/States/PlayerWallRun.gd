extends PlayerState


func _ready() -> void:
	state_name = PlayerState.WALL_RUN

func enter():
	state_owner.gravity_factor = 0
	if state_machine.previous_state == PlayerState.CEILLING_RUN:
		state_owner.velocity.y = abs(state_owner.velocity.x) + 100
	else: 
		state_owner.velocity.y = -abs(state_owner.velocity.x)
	
func exit():
	state_owner.velocity.x = state_owner.move_direction * abs(state_owner.velocity.y)
	state_owner.gravity_factor = 1


func physics_update(delta: float) -> void:
	state_owner.apply_speed_input()
	state_owner.apply_motion(delta, state_owner.SurfaceType.WALL)

	if state_owner.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		return

	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to(PlayerState.JUMP)
		return

	if Input.is_action_just_pressed("down"):
		state_machine.transition_to(PlayerState.SLAM)
		return

	if state_owner.is_on_ceiling() and state_owner.move_direction != 0 and state_machine.previous_state != PlayerState.CEILLING_RUN:
		state_machine.transition_to(PlayerState.CEILLING_RUN)
		return

	if not state_owner.is_on_wall():
		state_machine.transition_to(state_owner.grounded_state_name())
		return

	state_owner.anim_move()
	state_owner.move_and_slide()
