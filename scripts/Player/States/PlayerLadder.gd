extends PlayerState


func _ready() -> void:
	state_name = PlayerState.LADDER


func enter() -> void:
	player.gravity_factor = 0.0
	player.velocity = Vector2.ZERO


func exit() -> void:
	player.gravity_factor = player.default_gravity_factor


func physics_update(delta: float) -> void:
	if not player.is_on_ladder():
		state_machine.transition_to(player.grounded_state_name() if player.is_on_floor() else PlayerState.FALL)
		return

	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to(PlayerState.JUMP)
		return

	var ladder := player.active_ladder
	var climb_speed := ladder.climb_speed if ladder else player.ladder_climb_speed
	var horizontal_input := Input.get_axis("left", "right")
	var vertical_input := Input.get_axis("up", "down")

	player.velocity.x = move_toward(player.velocity.x, horizontal_input * climb_speed, player.acceleration * delta)
	player.velocity.y = vertical_input * climb_speed

	if horizontal_input > 0:
		player.anim.scale.x = 1
	elif horizontal_input < 0:
		player.anim.scale.x = -1

	player.anim.play("walk" if vertical_input != 0.0 or horizontal_input != 0.0 else "idle")
	player.move_and_slide()
