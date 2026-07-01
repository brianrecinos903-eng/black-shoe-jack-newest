extends PlayerState

func enter() -> void:
	player.velocity.x = 0
	player.animate("Death")

func physics_update(_delta: float) -> void:
	player.apply_gravity(_delta)
	player.velocity.x = 0
	player.move_and_slide()
