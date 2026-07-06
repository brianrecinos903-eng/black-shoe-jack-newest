extends PlayerState



func _ready() -> void:
	state_name = PlayerState.SLIDE

func enter():
	player.crouch_collider()
	player.velocity.x = player.move_direction * player.slide_velocity

func exit():
	player.uncrouch_collider()

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)

	if player.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		return

	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to(PlayerState.JUMP)
		return

	if player.is_falling():
		state_machine.transition_to(PlayerState.FALL)
		return

	if abs(player.velocity.x) <= 500:
		var next_state := player.grounded_state_name()
		if Input.is_action_pressed("down"):
			next_state = PlayerState.CROUCH

		state_machine.transition_to(next_state)
		player.move_and_slide()
		return


	player.velocity.x = move_toward(player.velocity.x, 0, player.slide_velocity * delta)
	print(player.velocity.x)


	player.anim.play("crawl")
	player.move_and_slide()
