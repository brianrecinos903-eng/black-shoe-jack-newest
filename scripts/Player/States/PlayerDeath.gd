extends PlayerState



func _ready() -> void:
	state_name = PlayerState.DEATH

func enter() -> void:
	state_owner.death_timer.start()
	state_owner.is_alive = false
	state_owner.velocity.x = 0
	state_owner.anim.play("death")

func physics_update(_delta: float) -> void:
	if not state_owner.in_water:
		state_owner.apply_gravity(_delta)
	state_owner.velocity.x = 0
	state_owner.move_and_slide()

func death_timer_end() -> void:
	state_owner.health = 3
	state_owner.is_alive = true
	state_owner.global_position = state_owner.last_checkpoint
	state_machine.transition_to(state_owner.grounded_state_name())
	
