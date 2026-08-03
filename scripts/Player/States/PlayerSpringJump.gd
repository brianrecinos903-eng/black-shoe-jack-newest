extends PlayerState

var ignore_floor_check := true

func _ready() -> void:
	state_name = PlayerState.SPRING

func enter():
	state_owner.gravity_factor = state_owner.jump_gravity_factor
	ignore_floor_check = true
	state_owner.velocity.x = state_owner.move_direction * state_owner.spring_jump_impulse.x
	state_owner.velocity.y = state_owner.spring_jump_impulse.y


func physics_update(delta: float) -> void:
	state_owner.apply_gravity(delta)
	state_owner.apply_speed_input()
	state_owner.apply_motion(delta)

	if state_owner.slam_area.disabled == false:
		Helpers.wait(0.5)
		state_owner.slam_area.disabled = true


	if state_owner.is_on_ceiling() and state_owner.move_direction != 0:
		state_machine.transition_to(PlayerState.CEILLING_RUN)
		return

	if state_owner.velocity.y >= 100:
		state_machine.transition_to(PlayerState.FALL)
		return

	if state_owner.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		return

	if Input.is_action_just_pressed("down"):
		state_machine.transition_to(PlayerState.SLAM)
		return


	if Input.is_action_just_released("jump"):
		state_machine.transition_to(PlayerState.FALL)
		return
	


	if not ignore_floor_check and state_owner.is_on_floor():
		var next_state := (state_owner as Player).grounded_state_name()
		state_machine.transition_to(next_state)
		state_owner.move_and_slide()
		return

	state_owner.velocity.x = move_toward(state_owner.velocity.x, 0, state_owner.spring_jump_impulse.x * delta)

	state_owner.anim.play("jump")
	state_owner.move_and_slide()
	ignore_floor_check = false
