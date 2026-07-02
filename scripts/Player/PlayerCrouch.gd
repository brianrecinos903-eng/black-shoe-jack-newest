extends PlayerState

@onready var collider: CollisionShape2D = $"../../CollisionShape2D"

@export var crouch_collider_scale: float = 0.5


var standing_collider_pos = 25
var crouch_collider_pos = 44

func enter():
	collider.scale.y = crouch_collider_scale
	collider.position.y = crouch_collider_pos

func exit():
	collider.position.y = standing_collider_pos
	collider.scale.y = 1



func physics_update(delta: float) -> void:
	print("Collider scale", collider.scale.y)
	player.apply_gravity(delta)
	player.apply_horizontal_movement()
	player.apply_speed_input()

	if player.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		return

	if Input.is_action_just_pressed("jump"):
		player.velocity.y = player.jump_velocity
		state_machine.transition_to(PlayerState.JUMP)
		return

	if player.is_falling():
		state_machine.transition_to(PlayerState.FALL)
		return

	if player.direction == 0:
		state_machine.transition_to(PlayerState.IDLE)
		return


	#player.animate("Crouch")
	player.move_and_slide()
