extends PlayerState

@export var button_hold_time := 1.5

var spring_hold_elapsed := 0.0
var spring_ready := false


func _ready() -> void:
	state_name = PlayerState.SLAM


func exit_state() -> void:
	state_machine.transition_to(state_owner.grounded_state_name())
	state_owner.move_and_slide()


func exit() -> void:
	state_owner.gravity_factor = state_owner.default_gravity_factor


func handle_bounce() -> void:
	if state_owner.bounces_left == 0:
		exit_state()
		return
	state_owner.velocity.y = -state_owner.jump_impulse
	state_owner.bounces_left -= 1


func enter() -> void:
	spring_hold_elapsed = 0.0
	spring_ready = false
	state_owner.speed_multiplier = 0.2
	state_owner.bounces_left = state_owner.max_bounces
	if not state_owner.in_water:
		state_owner.gravity_factor = state_owner.fall_gravity_factor


func update_spring_charge(delta: float) -> void:
	if Input.is_action_pressed("down"):
		spring_hold_elapsed += delta
		spring_ready = spring_hold_elapsed >= button_hold_time
	else:
		spring_hold_elapsed = 0.0
		spring_ready = false


func physics_update(delta: float) -> void:
	update_spring_charge(delta)
	state_owner.apply_gravity(delta)
	state_owner.apply_motion(delta)
	state_owner.move_and_slide()

	if Input.is_action_just_pressed("up"):
		exit_state()
		return

	if state_owner.is_on_floor():
		if not Input.is_action_pressed("down"):
			handle_bounce()
			return
		if spring_ready:
			state_owner.camera_2d.shake(state_owner.slam_shake_factor)
			state_owner.slam_area.disabled = false
			state_machine.transition_to(PlayerState.SPRING)
			return

	state_owner.anim.play("slam")
