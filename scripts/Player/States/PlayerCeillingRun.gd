extends PlayerState


func _ready() -> void:
	state_name = PlayerState.CEILLING_RUN

func enter():
	player.gravity_factor = -1
	
func exit():
	player.gravity_factor = 1
 

func physics_update(delta: float) -> void:
	player.apply_horizontal_movement()
	player.apply_speed_input()

	player.velocity.y = -100
	if player.is_hurt:
		state_machine.transition_to(PlayerState.HURT)
		return

	if not player.is_level_within_distance(Vector2.UP, 70) or Input.is_action_just_pressed("jump"):
		print("Player not on ceilling")
		player.velocity.y = -200
		state_machine.transition_to(PlayerState.FALL)
		return

	player.anim_move()
	player.move_and_slide()
