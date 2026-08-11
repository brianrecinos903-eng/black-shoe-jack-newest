extends PlayerState


func _ready() -> void:
	state_name = PlayerState.LADDER


func enter() -> void:
	state_owner.gravity_factor = 0.0
	state_owner.velocity = Vector2.ZERO


func exit() -> void:
	state_owner.gravity_factor = state_owner.default_gravity_factor


func physics_update(delta: float) -> void:
	if not state_owner.is_on_ladder():
		state_machine.transition_to(state_owner.grounded_state_name() if state_owner.is_on_floor() else PlayerState.FALL)
		return

	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to(PlayerState.JUMP)
		return

	var ladder := (state_owner as Player).active_ladder
	var climb_speed := ladder.climb_speed if ladder else (state_owner as Player).ladder_climb_speed
	var horizontal_input := Input.get_axis("left", "right")
	var vertical_input := Input.get_axis("up", "down")

	state_owner.velocity.x = move_toward(state_owner.velocity.x, horizontal_input * climb_speed, state_owner.acceleration * delta)
	state_owner.velocity.y = vertical_input * climb_speed

	if horizontal_input > 0:
		state_owner.anim.scale.x = 1
	elif horizontal_input < 0:
		state_owner.anim.scale.x = -1

	state_owner.anim.play("walk" if vertical_input != 0.0 or horizontal_input != 0.0 else "idle")
	state_owner.move_and_slide()
