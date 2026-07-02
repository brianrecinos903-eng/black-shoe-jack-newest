extends PlayerState

@export var knockback: Vector2 = Vector2(100, 100)
@onready var stunned_timer: Timer = $StunTimer
@onready var collider: CollisionShape2D = $"../../CollisionShape2D"

func enter() -> void:
	player.can_be_hurt = false

	if player.health <= 0:
		player.is_hurt = false
		player.can_be_hurt = true
		player.kill_player()
		state_machine.transition_to(PlayerState.DEATH)
		return

	player.velocity.x = knockback.x * -player.face_direction
	player.velocity.y = knockback.y * Vector2.UP.y
		
	stunned_timer.start()
	
	# player.animate("Hurt")

func physics_update(_delta: float) -> void:
	player.apply_gravity(_delta)
	player.move_and_slide()

func _on_stun_timer_timeout() -> void:
	collider.disabled = false
	player.is_hurt = false
	player.can_be_hurt = true
	state_machine.transition_to(player.grounded_state_name())
