extends PlayerState

@export var button_hold_time = 1.5

var exited = false

func exit_state() -> void:
	var next_state := player.grounded_state_name()
	state_machine.transition_to(next_state)
	player.animate(next_state)
	player.move_and_slide()
	exited = true
	print("Exited state: ", exited)
	return

func handle_bounce() -> void:
	if player.bounces_left == 0:
		exit_state()
		return
	elif player.bounces_left > 0:
		player.velocity.y = player.jump_velocity
		player.bounces_left -= 1


func handle_key_hold() -> void:
	if not Input.is_action_pressed("down"):
		handle_bounce()
		return
	if player.direction != 0:
		exit_state()
		return
	Helpers.wait(button_hold_time)
	print("Exited: ", exited)
	if exited or not Input.is_action_pressed("down"):
		return

	state_machine.transition_to(PlayerState.SPRING)


func enter() -> void:
	exited = false
	player.speed_mult = 0.2
	player.bounces_left = player.max_bounces

func physics_update(delta: float) -> void:
	player.apply_fall(delta)
	player.apply_horizontal_movement()

	if player.is_on_floor():
		handle_key_hold()
		

	player.animate("Slam")
	player.move_and_slide()
