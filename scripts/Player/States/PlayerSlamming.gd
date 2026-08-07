extends PlayerState

@export var button_hold_time := 1.5

var spring_hold_elapsed := 0.0
var spring_ready := false


func _ready() -> void:
	state_name = PlayerState.SLAM


func exit_state() -> void:
	state_machine.transition_to(player.grounded_state_name())
	player.move_and_slide()


func exit() -> void:
	player.gravity_factor = player.default_gravity_factor


func handle_bounce() -> void:
	if player.bounces_left == 0:
		exit_state()
		return
	player.velocity.y = -player.jump_impulse
	player.bounces_left -= 1


func enter() -> void:
	spring_hold_elapsed = 0.0
	spring_ready = false
	player.speed_multiplier = 0.2
	player.bounces_left = player.max_bounces
	if not player.in_water:
		player.gravity_factor = player.fall_gravity_factor


func update_spring_charge(delta: float) -> void:
	if Input.is_action_pressed("down"):
		spring_hold_elapsed += delta
		spring_ready = spring_hold_elapsed >= button_hold_time
	else:
		spring_hold_elapsed = 0.0
		spring_ready = false


func physics_update(delta: float) -> void:
	update_spring_charge(delta)
	player.apply_gravity(delta)
	player.apply_motion(delta)
	player.move_and_slide()

	if Input.is_action_just_pressed("up"):
		exit_state()
		return

	if player.is_on_floor():
		if not Input.is_action_pressed("down"):
			handle_bounce()
			return
		if spring_ready:
			player.camera_2d.shake(player.slam_shake_factor)
			player.slam_area.disabled = false
			state_machine.transition_to(PlayerState.SPRING)
			return

	player.anim.play("slam")
