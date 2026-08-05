extends PlayerState

@export var button_hold_time = 1.5


var exited = false

func _ready() -> void:
	state_name = PlayerState.SLAM

func exit_state() -> void:
	var next_state := (state_owner as Player).grounded_state_name()
	state_machine.transition_to(next_state)
	state_owner.move_and_slide()
	exited = true
	return


func exit():
	state_owner.gravity_factor = state_owner.default_gravity_factor

func handle_bounce() -> void:
	print("handling bounce")
	if state_owner.bounces_left == 0:
		exit_state()
		return
	if state_owner.bounces_left > 0:
		state_owner.velocity.y = -state_owner.jump_impulse
		state_owner.bounces_left -= 1
		return


func enter() -> void:
	print("Now in slam")
	exited = false
	state_owner.speed_multiplier = 0.2
	state_owner.bounces_left = state_owner.max_bounces
	if not state_owner.in_water:
		state_owner.gravity_factor = state_owner.fall_gravity_factor

func physics_update(delta: float) -> void:
	state_owner.apply_gravity(delta)
	state_owner.apply_motion(delta)
	state_owner.move_and_slide()

	if Input.is_action_just_pressed("up"):
		exit_state()
		return
	if state_owner.is_on_floor():
		print(state_owner.bounces_left)
		if not Input.is_action_pressed("down"):
			handle_bounce()
			return
		Helpers.wait(button_hold_time)
		print("waited")
		Helpers.print_log("Exited: %s" % exited, state_owner.enable_debug)
		if exited or not Input.is_action_pressed("down"):
			return

		state_owner.camera_2d.shake(state_owner.slam_shake_factor)
		state_owner.slam_area.disabled = false
		Helpers.print_log("Slam enabled", state_owner.enable_debug)
		state_machine.transition_to(PlayerState.SPRING)
		return
		

	state_owner.anim.play("slam")


	
