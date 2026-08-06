extends PlayerState


func _ready() -> void:
	state_name = PlayerState.CEILLING_RUN

func enter():
	state_owner.gravity_factor = -1
	state_owner.anim.position.y = state_owner.inverse_sprite_pos
	if state_machine.previous_state == PlayerState.WALL_RUN:
		state_owner.velocity.x = abs(state_owner.velocity.y) * -state_owner.move_direction 
	
func exit():
	state_owner.gravity_factor = 1
	state_owner.anim.position.y = state_owner.default_sprite_pos
 
func pull_player():
	state_owner.velocity.y = -100


func physics_update(delta: float) -> void:
	state_owner.apply_motion(delta, state_owner.SurfaceType.CEILLING)
	state_owner.apply_speed_input()

	pull_player()
	if state_owner.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		return

	if state_owner.is_on_wall():
		Helpers.print_log("player wall normal: %s " % (state_owner.get_wall_normal().x == state_owner.move_direction), state_owner.enable_debug)
		if Input.is_action_pressed("down") and -state_owner.get_wall_normal().x == state_owner.move_direction:
			state_machine.transition_to(PlayerState.WALL_RUN)
			return

	if not state_owner.is_level_within_distance(Vector2.UP, state_owner.acceptable_distance) or Input.is_action_just_pressed("jump"):
		Helpers.print_log("Player not on ceilling", state_owner.enable_debug)
		state_machine.transition_to(PlayerState.JUMP)
		return

	if state_owner.move_direction != 0:
		state_owner.anim_move()
	else:
		state_owner.anim.play("idle")

	state_owner.move_and_slide()
