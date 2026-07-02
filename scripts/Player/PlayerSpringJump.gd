extends PlayerState

var ignore_floor_check := true


func enter():
	ignore_floor_check = true


func physics_update(delta: float) -> void:
	player.apply_jump(delta)
	player.apply_horizontal_movement()
	player.apply_speed_input()


	if Input.is_action_just_pressed("down"):
		state_machine.transition_to("Slam")
		return


	if Input.is_action_just_released("jump"):
		state_machine.transition_to("Fall")
		return


	if not ignore_floor_check and player.is_on_floor():
		state_machine.transition_to(player.grounded_state_name())
		return

	player.animate("Jump")
	player.move_and_slide()
	ignore_floor_check = false
