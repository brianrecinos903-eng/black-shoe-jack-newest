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
	print("handling bounce")
	if player.bounces_left == 0:
		exit_state()
		return
	if player.bounces_left > 0:
		player.velocity.y = -player.jump_impulse
		player.bounces_left -= 1
		return


func enter() -> void:
	print("Now in slam")
	exited = false
	player.speed_multiplier = 0.2
	player.bounces_left = player.max_bounces
	if not player.in_water:
		player.gravity_factor = player.fall_gravity_factor

func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.apply_motion(delta)
	player.move_and_slide()

	if Input.is_action_just_pressed("up"):
		exit_state()
		return
	if player.is_on_floor():
		print(player.bounces_left)
		if not Input.is_action_pressed("down"):
			handle_bounce()
			return
		Helpers.wait(button_hold_time)
		print("waited")
		Helpers.print_log("Exited: %s" % exited, player.enable_debug)
		if exited or not Input.is_action_pressed("down"):
			return

		player.camera_2d.shake(player.slam_shake_factor)
		player.slam_area.disabled = false
		Helpers.print_log("Slam enabled", player.enable_debug)
		state_machine.transition_to(PlayerState.SPRING)
		return
		

	player.anim.play("slam")


	
