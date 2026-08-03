extends enemy 

signal on_player_bounce 

func _ready() -> void: 
	direction = 1 
	anim = $AnimatedSprite2D
	anim.play($"State Machine".initial_state.state_name)

func _process(delta: float) -> void:
	position.x += speed * direction * delta
