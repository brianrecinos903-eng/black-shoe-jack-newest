extends PlayerState

func _ready() -> void:
	state_name = PlayerState.CROUCH

func enter():
	if player.in_water:
		player.gravity_factor = player.water_gravity_factor * 2
	else:
		if player.is_on_platform:
			player.position.y += 10
		player.crouch_collider()

func exit():
	if player.in_water:
		player.gravity_factor = player.water_gravity_factor
	else:
		player.uncrouch_collider()


func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.apply_motion(delta)

	
	if player.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		return

	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to(PlayerState.JUMP)
		return

	if player.is_falling():
		state_machine.transition_to(PlayerState.FALL)
		return

	if Input.is_action_just_released("down"):
		state_machine.transition_to(PlayerState.IDLE)
		return


	if player.move_direction != 0:
		player.anim.play("crawl")
	else:
		player.anim.play("crouch")


	player.move_and_slide()
