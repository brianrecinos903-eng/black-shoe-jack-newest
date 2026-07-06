extends PlayerState
	
func _ready() -> void:
	state_name = PlayerState.IDLE

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.apply_horizontal_movement()
	player.apply_speed_input()

	if player.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		return

	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to(PlayerState.JUMP)
		return

	if player.is_falling():
		state_machine.transition_to(PlayerState.FALL)
		return

	if player.move_direction != 0:
		state_machine.transition_to(PlayerState.MOVE)
		return

	if Input.is_action_pressed("down"):
		state_machine.transition_to(PlayerState.CROUCH)
		return

	player.anim.play("idle")
	player.move_and_slide()
