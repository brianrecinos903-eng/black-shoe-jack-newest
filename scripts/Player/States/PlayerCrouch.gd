extends PlayerState


func _ready() -> void:
	state_name = PlayerState.CROUCH


func enter():
	if state_owner.in_water:
		state_owner.gravity_factor = state_owner.water_gravity_factor
		state_owner.velocity.y = state_owner.swim_down_impulse
	else:
		if state_owner.is_on_platform:
			state_owner.position.y += state_owner.platform_threshold
		state_owner.crouch_collider()


func exit():
	if state_owner.in_water:
		state_owner.gravity_factor = state_owner.water_gravity_factor
		state_owner.velocity.y = 0
	else:
		state_owner.uncrouch_collider()


func physics_update(delta: float) -> void:
	state_owner.apply_motion(delta)
	state_owner.apply_gravity(delta)
	state_owner.move_and_slide()
	if not state_owner.in_water:
		if state_owner.is_falling():
			state_machine.transition_to(PlayerState.FALL)
			return
		if Input.is_action_just_pressed("jump"):
			state_machine.transition_to(PlayerState.JUMP)
			return
	else:
		if Input.is_action_just_pressed("up"):
			state_machine.transition_to(PlayerState.JUMP)
			return
	if state_owner.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		return
	if Input.is_action_just_released("down"):
		state_machine.transition_to(PlayerState.IDLE)
		return
	if state_owner.move_direction != 0:
		state_owner.anim.play("crawl")
	else:
		state_owner.anim.play("crouch")
