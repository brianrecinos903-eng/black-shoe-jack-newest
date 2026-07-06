extends PlayerState

func apply_wallrun() -> void:
	player.move_direction = Input.get_axis("left", "right")
	if player.move_direction != 0:
		player.velocity.y = -player.speed * player.acceleration
	else:
		player.velocity.y = move_toward(player.velocity.y, 0, -player.speed)
		player.acceleration = 1


func _ready() -> void:
	state_name = PlayerState.WALL_RUN

func enter():
	player.gravity_factor = 0
	player.velocity.y = -abs(player.velocity.x)
	print("wall run dimension ", player.move_direction)
	
func exit():
	player.velocity.x = player.move_direction * abs(player.velocity.y)
	print("player velocity x: ", player.velocity.x)
	player.gravity_factor = 1


func physics_update(delta: float) -> void:
	apply_wallrun()
	player.apply_speed_input()

	if player.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		return

	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to(PlayerState.JUMP)
		return

	if Input.is_action_pressed("down"):
		state_machine.transition_to(PlayerState.SLAM)
		return

	if player.is_falling():
		state_machine.transition_to(PlayerState.FALL)
		return

	if player.is_on_ceiling() and player.move_direction != 0:
		state_machine.transition_to(PlayerState.CEILLING_RUN)
		return

	if not player.is_on_wall():
		state_machine.transition_to(player.grounded_state_name())
		return

	player.anim_move()
	player.move_and_slide()
