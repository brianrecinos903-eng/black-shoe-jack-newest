extends PlayerState

var water_idle_time := 0.0

func _ready() -> void:
	state_name = PlayerState.IDLE


func enter():
	water_idle_time = 0.0


func physics_update(delta: float) -> void:
	state_owner.apply_gravity(delta)
	state_owner.apply_motion(delta)
	state_owner.apply_speed_input()
	if state_owner.in_water:
		state_owner.apply_water_drag(delta)
		if state_owner.move_direction == 0:
			water_idle_time += delta
		else:
			water_idle_time = 0.0
		if water_idle_time >= state_owner.water_sink_delay:
			state_owner.velocity.y = state_owner.water_sink_speed
			state_machine.transition_to(PlayerState.FALL)
			return
	if state_owner.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		return
	if not state_owner.in_water:
		if state_owner.is_falling():
			state_machine.transition_to(PlayerState.FALL)
			return
		if Input.is_action_just_pressed("jump"):
			state_machine.transition_to(PlayerState.JUMP)
			return
	else:
		if Input.is_action_just_pressed("up"):
			state_machine.transition_to(PlayerState.JUMP)
			return
	if state_owner.move_direction != 0:
		state_machine.transition_to(PlayerState.MOVE)
		return
	if Input.is_action_pressed("down"):
		state_machine.transition_to(PlayerState.CROUCH)
		return
	state_owner.anim.play("idle")
	state_owner.move_and_slide()
