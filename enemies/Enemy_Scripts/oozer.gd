extends enemy

func _ready() -> void: 
	anim = $AnimatedSprite2D
	anim.play(stateMachine.initial_state.state_name)
