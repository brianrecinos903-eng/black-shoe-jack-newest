extends PlayerState


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
	player.apply_motion(delta, player.SurfaceType.WALL)

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
