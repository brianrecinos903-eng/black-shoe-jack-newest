extends PlayerState

@export var knockback: Vector2 = Vector2(100, 100)
@export var stun_time: float = 0.5

func enter() -> void:
	player.velocity.x = knockback.x * -player.face_direction
	player.velocity.y = knockback.y * Vector2.UP.y

	Helpers.wait(stun_time)
	
	if player.health <= 0:
		player.is_hurt = false
		player.kill_player()
		state_machine.transition_to(PlayerState.DEATH)
		return

	player.is_hurt = false
	# player.animate("Hurt")
	state_machine.transition_to(player.grounded_state_name())
		
	

func physics_update(_delta: float) -> void:
	player.apply_gravity(_delta)
	player.move_and_slide()
