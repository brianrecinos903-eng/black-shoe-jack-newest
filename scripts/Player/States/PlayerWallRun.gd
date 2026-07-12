extends PlayerState

func apply_wallrun(wall_run_direction: float, delta: float) -> void:
	player.move_direction = Input.get_axis("left", "right")
	var desired_speed = player.walk_speed

	if player.speed_multiplier > 1:
		desired_speed = player.max_speed
	else:
		player.desired_speed = player.walk_speed

	if player.move_direction != 0:
		player.velocity.y = wall_run_direction * player.max_wallrun_speed * player.speed_multiplier 
	else:
		player.velocity.y = move_toward(player.velocity.y, 0, player.friction_force * delta * player.speed_multiplier)
		player.speed_multiplier = 1

	if player.move_direction > 0:
		player.anim.scale.x = 1
		player.face_direction = 1
	elif player.move_direction < 0:
		player.anim.scale.x = -1
		player.face_direction = -1
	
	if player.gravity_factor == -1:
		player.anim.scale.y = -1
	else: 
		player.anim.scale.y = 1


func _ready() -> void:
	state_name = PlayerState.WALL_RUN

func enter():
	player.gravity_factor = 0
	if state_machine.previous_state == PlayerState.CEILLING_RUN:
		player.velocity.y = abs(player.velocity.x) + 100
	else: 
		player.velocity.y = -abs(player.velocity.x)
	
func exit():
	player.velocity.x = player.move_direction * abs(player.velocity.y)
	player.gravity_factor = 1


func physics_update(delta: float) -> void:
	player.apply_speed_input()
	if state_machine.previous_state == PlayerState.CEILLING_RUN:
		apply_wallrun(1, delta)
	else:
		apply_wallrun(-1, delta)
		if player.is_falling():
			state_machine.transition_to(PlayerState.FALL)
			return

	if player.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		return

	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to(PlayerState.JUMP)
		return

	if Input.is_action_just_pressed("down"):
		state_machine.transition_to(PlayerState.SLAM)
		return

	if player.is_on_ceiling() and player.move_direction != 0 and state_machine.previous_state != PlayerState.CEILLING_RUN:
		state_machine.transition_to(PlayerState.CEILLING_RUN)
		return

	if not player.is_on_wall():
		state_machine.transition_to(player.grounded_state_name())
		return

	player.anim_move()
	player.move_and_slide()
