extends PlayerState


func _ready() -> void:
	state_name = PlayerState.CEILLING_RUN

func enter():
	player.gravity_factor = -1
	player.anim.position.y = player.inverse_sprite_pos
	if state_machine.previous_state == PlayerState.WALL_RUN:
		player.velocity.x = abs(player.velocity.y) * -player.move_direction 
	
func exit():
	player.gravity_factor = 1
	player.anim.position.y = player.default_sprite_pos
 

func physics_update(delta: float) -> void:
	player.apply_motion(delta, player.SurfaceType.CEILLING)
	player.apply_speed_input()

	player.velocity.y = -100
	if player.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		return

	if player.is_on_wall():
		Helpers.print_log("player wall normal: %s " % (player.get_wall_normal().x == player.move_direction), player.enable_debug)
		if Input.is_action_pressed("down") and -player.get_wall_normal().x == player.move_direction:
			state_machine.transition_to(PlayerState.WALL_RUN)
			return

	if not player.is_level_within_distance(Vector2.UP, 70) or Input.is_action_just_pressed("jump"):
		Helpers.print_log("Player not on ceilling", player.enable_debug)
		state_machine.transition_to(PlayerState.JUMP)
		return

	if player.move_direction != 0:
		player.anim_move()
	else:
		player.anim.play("idle")

	player.move_and_slide()
