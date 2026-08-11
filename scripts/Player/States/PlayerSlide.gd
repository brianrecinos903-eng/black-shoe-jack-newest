extends PlayerState



func _ready() -> void:
	state_name = PlayerState.SLIDE

func enter():
	state_owner.crouch_collider()
	state_owner.velocity.x = state_owner.move_direction * state_owner.slide_impulse

func exit():
	state_owner.uncrouch_collider()

func physics_update(delta: float) -> void:
	state_owner.apply_gravity(delta)

	if state_owner.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		return

	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to(PlayerState.JUMP)
		return

	if state_owner.is_falling():
		state_machine.transition_to(PlayerState.FALL)
		return

	if abs(state_owner.velocity.x) <= 500:
		var next_state := (state_owner as Player).grounded_state_name()
		if Input.is_action_pressed("down"):
			next_state = PlayerState.CROUCH

		state_machine.transition_to(next_state)
		state_owner.move_and_slide()
		return


	state_owner.velocity.x = move_toward(state_owner.velocity.x, 0, state_owner.slide_impulse * delta)


	state_owner.anim.play("crawl")
	state_owner.move_and_slide()
