extends PlayerState

# After a charged slam, hold Q at each surface to continue the bounce chain.
var spring_direction := -1.0
var bounces_left := 0
var waiting_for_surface_exit := false
var chain_enabled := false


func _ready() -> void:
	state_name = PlayerState.SPRING


func enter() -> void:
	player.slam_area.disabled = true
	chain_enabled = state_machine.previous_state == PlayerState.SLAM
	bounces_left = player.spring_jump_max_bounces
	spring_direction = 1.0 if player.is_on_ceiling() else -1.0
	waiting_for_surface_exit = player.is_on_ceiling() or player.is_on_floor()
	launch()


func exit() -> void:
	player.gravity_factor = player.default_gravity_factor


func launch() -> void:
	player.gravity_factor = player.jump_gravity_factor if spring_direction < 0.0 else player.fall_gravity_factor
	player.velocity.y = abs(player.spring_jump_impulse.y) * spring_direction
	player.velocity.x = player.move_direction * player.spring_jump_impulse.x


func can_bounce() -> bool:
	return bounces_left != 0


func bounce_from_surface() -> void:
	if not can_bounce():
		exit_at_surface()
		return
	if bounces_left > 0:
		bounces_left -= 1
	spring_direction = -1.0 if player.is_on_floor() else 1.0
	waiting_for_surface_exit = true
	launch()


func exit_at_surface() -> void:
	if player.is_on_floor():
		state_machine.transition_to(player.grounded_state_name())
	else:
		state_machine.transition_to(PlayerState.FALL)


func physics_update(delta: float) -> void:
	player.apply_speed_input()
	player.apply_motion(delta)

	if waiting_for_surface_exit:
		if not player.is_on_floor() and not player.is_on_ceiling():
			waiting_for_surface_exit = false
	elif player.is_on_floor() or player.is_on_ceiling():
		if chain_enabled and Input.is_action_pressed("spring_jump"):
			bounce_from_surface()
		else:
			exit_at_surface()
		return

	if player.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		return

	player.apply_gravity(delta)
	player.anim.play("jump")
	player.move_and_slide()
