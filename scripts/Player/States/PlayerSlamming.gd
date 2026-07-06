extends PlayerState

@export var button_hold_time = 1.5

var exited = false

func _ready() -> void:
	state_name = PlayerState.SLAM

func exit_state() -> void:
	var next_state := player.grounded_state_name()
	state_machine.transition_to(next_state)
	player.move_and_slide()
	exited = true
	return


func exit():
	player.gravity_factor = player.default_gravity_factor

func handle_bounce() -> void:
	if player.bounces_left == 0:
		exit_state()
		return
	if player.bounces_left > 0:
		player.velocity.y = player.jump_power
		player.bounces_left -= 1


func enter() -> void:
	exited = false
	player.acceleration = 0.2
	player.bounces_left = player.max_bounces
	player.gravity_factor = player.fall_gravity_factor

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.apply_horizontal_movement()

	if player.is_on_floor():
		if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
			exit_state()
			return
		if not Input.is_action_pressed("down"):
			handle_bounce()
			return
		Helpers.wait(button_hold_time)
		print("Exited: ", exited)
		if exited or not Input.is_action_pressed("down"):
			return

		player.camera_2d.shake(player.slam_shake_factor)
		state_machine.transition_to(PlayerState.SPRING)
		return
		

	player.anim.play("slam")
	player.move_and_slide()
