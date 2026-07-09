extends PlayerState

@onready var stunned_timer: Timer = $StunTimer

func _ready() -> void:
	state_name = PlayerState.HURT

func enter() -> void:
	player.camera_2d.shake(player.hurt_shake_factor)
	player.can_be_hurt = false

	if player.health <= 0:
		player.is_hurt = false
		player.can_be_hurt = true
		state_machine.transition_to(PlayerState.DEATH)
		return

	player.velocity.x = player.dmg_knockback.x * -player.face_direction
	player.velocity.y = player.dmg_knockback.y * Vector2.UP.y
		
	stunned_timer.start()
	

func physics_update(_delta: float) -> void:
	player.apply_gravity(_delta)
	player.move_and_slide()
	# player.anim.play()

func _on_stun_timer_timeout() -> void:
	player.is_hurt = false
	player.can_be_hurt = true
	state_machine.transition_to(player.grounded_state_name())
