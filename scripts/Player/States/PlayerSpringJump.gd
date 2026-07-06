extends PlayerState

var ignore_floor_check := true

func _ready() -> void:
	state_name = PlayerState.SPRING

func enter():
	player.gravity_factor = player.jump_gravity_factor
	ignore_floor_check = true
	player.velocity.x = player.move_direction * player.spring_jump_power.x
	player.velocity.y = player.spring_jump_power.y


func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.apply_speed_input()
	if abs(player.velocity.x) <= 400:
		player.apply_horizontal_movement()

	if player.is_on_ceiling() and player.move_direction != 0:
		state_machine.transition_to(PlayerState.CEILLING_RUN)
		return

	if player.velocity.y >= 100:
		state_machine.transition_to(PlayerState.FALL)
		return

	if player.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		return

	if Input.is_action_just_pressed("down"):
		state_machine.transition_to(PlayerState.SLAM)
		return


	if Input.is_action_just_released("jump"):
		state_machine.transition_to(PlayerState.FALL)
		return
	


	if not ignore_floor_check and player.is_on_floor():
		var next_state := player.grounded_state_name()
		state_machine.transition_to(next_state)
		player.move_and_slide()
		return

	player.velocity.x = move_toward(player.velocity.x, 0, player.spring_jump_power.x * delta)

	player.anim.play("jump")
	player.move_and_slide()
	ignore_floor_check = false
