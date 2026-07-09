extends PlayerState

func _ready() -> void:
	state_name = PlayerState.DEATH

func enter() -> void:
	player.death_timer.start()
	player.is_alive = false
	player.velocity.x = 0
	player.anim.play("death")

func physics_update(_delta: float) -> void:
	player.apply_gravity(_delta)
	player.velocity.x = 0
	player.move_and_slide()

func death_timer_end() -> void:
	player.health = 3
	player.is_alive = true
	player.global_position = player.last_checkpoint
	state_machine.transition_to(player.grounded_state_name())
