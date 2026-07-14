extends PlayerState



func _ready() -> void:
	state_name = PlayerState.FALL

var ignore_floor_check := true

func enter():
	ignore_floor_check = true
	player.gravity_factor = player.fall_gravity_factor

func exit():
	player.gravity_factor = player.default_gravity_factor

func physics_update(delta):
	player.apply_gravity(delta)
	player.apply_motion(delta)
	player.apply_speed_input()


	Helpers.wait(player.coyote_timeframe)
	if Input.is_action_just_pressed("jump") and player.can_coyote:
		player.can_coyote = false
		state_machine.transition_to(PlayerState.JUMP)
		return


	if Input.is_action_just_pressed("down"):
		state_machine.transition_to(PlayerState.SLAM)
		return
		
	if player.speed_multiplier>= 1.5:
		if player.is_on_wall():
			state_machine.transition_to(PlayerState.WALL_RUN)
			return

	if not ignore_floor_check and player.is_on_floor():
		state_machine.transition_to(player.grounded_state_name())
		player.can_coyote = true
		return

	player.anim.play("jump")
	player.move_and_slide()
	ignore_floor_check = false
