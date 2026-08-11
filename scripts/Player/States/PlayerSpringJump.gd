extends PlayerState

# After a charged slam, hold Q at each surface to continue the bounce chain.
var spring_direction := -1.0
var bounces_left := 0
var waiting_for_surface_exit := false
var chain_enabled := false


func _ready() -> void:
	state_name = PlayerState.SPRING


func enter() -> void:
	state_owner.slam_area.disabled = true
	chain_enabled = state_machine.previous_state == PlayerState.SLAM
	bounces_left = state_owner.spring_jump_max_bounces
	spring_direction = 1.0 if state_owner.is_on_ceiling() else -1.0
	waiting_for_surface_exit = state_owner.is_on_ceiling() or state_owner.is_on_floor()
	launch()


func exit() -> void:
	state_owner.gravity_factor = state_owner.default_gravity_factor


func launch() -> void:
	state_owner.gravity_factor = state_owner.jump_gravity_factor if spring_direction < 0.0 else state_owner.fall_gravity_factor
	state_owner.velocity.y = abs(state_owner.spring_jump_impulse.y) * spring_direction
	state_owner.velocity.x = state_owner.move_direction * state_owner.spring_jump_impulse.x


func can_bounce() -> bool:
	return bounces_left != 0


func bounce_from_surface() -> void:
	if not can_bounce():
		exit_at_surface()
		return
	if bounces_left > 0:
		bounces_left -= 1
	spring_direction = -1.0 if state_owner.is_on_floor() else 1.0
	waiting_for_surface_exit = true
	launch()


func exit_at_surface() -> void:
	if state_owner.is_on_floor():
		state_machine.transition_to(state_owner.grounded_state_name())
	else:
		state_machine.transition_to(PlayerState.FALL)


func physics_update(delta: float) -> void:
	state_owner.apply_speed_input()
	state_owner.apply_motion(delta)

	if waiting_for_surface_exit:
		if not state_owner.is_on_floor() and not state_owner.is_on_ceiling():
			waiting_for_surface_exit = false
	elif state_owner.is_on_floor() or state_owner.is_on_ceiling():
		if chain_enabled and Input.is_action_pressed("spring_jump"):
			bounce_from_surface()
		else:
			exit_at_surface()
		return

	if state_owner.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		return

	state_owner.apply_gravity(delta)
	state_owner.anim.play("jump")
	state_owner.move_and_slide()
