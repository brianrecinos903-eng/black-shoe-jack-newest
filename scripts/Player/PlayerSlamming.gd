extends PlayerState

func enter() -> void:
	player.speed_mult = 0.2
	player.bounces_left = player.max_bounces

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.apply_horizontal_movement()

	if player.is_on_floor():
		if Input.is_action_pressed("down") or player.bounces_left == 0:
			var next_state := player.grounded_state_name()
			state_machine.transition_to(next_state)
			player.animate(next_state)
			player.move_and_slide()
			return
		elif player.bounces_left > 0:
			player.velocity.y = player.jump_velocity
			player.bounces_left -= 1

	player.animate("Slam")
	player.move_and_slide()
