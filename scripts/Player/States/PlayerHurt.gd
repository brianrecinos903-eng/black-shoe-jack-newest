extends PlayerState

@onready var stunned_timer: Timer = $StunTimer

func _ready() -> void:
	state_name = PlayerState.HURT

func enter() -> void:
	if state_owner.in_water:
		state_owner.gravity_factor = state_owner.water_gravity_factor 
	state_owner.camera_2d.shake(state_owner.hurt_shake_factor)
	state_owner.can_be_hurt = false

	if state_owner.health <= 0:
		state_owner.is_hurt = false
		state_owner.can_be_hurt = true
		state_machine.transition_to(PlayerState.DEATH)
		state_owner.reset_health()
		return

	if state_owner.dmg_source == Helpers.DamageType.TRAP:
		state_owner.velocity = state_owner.trap_knockback
	else:
		state_owner.velocity.x = state_owner.dmg_knockback.x * -state_owner.move_direction
		state_owner.velocity.y = state_owner.dmg_knockback.y * Vector2.UP.y
		
	stunned_timer.start()
	
func exit():
	if state_owner.in_water:
		state_owner.gravity_factor = state_owner.water_gravity_factor 

func physics_update(_delta: float) -> void:
	state_owner.apply_motion(_delta)
	if not state_owner.in_water:
		state_owner.apply_gravity(_delta)
	state_owner.move_and_slide()
	
	# state_owner.anim.play()

func _on_stun_timer_timeout() -> void:
	state_owner.is_hurt = false
	state_owner.can_be_hurt = true
	state_machine.transition_to(state_owner.grounded_state_name())
