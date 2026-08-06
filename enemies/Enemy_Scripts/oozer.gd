extends enemy

func _ready() -> void: 
	anim = $AnimatedSprite2D
	anim.play("Idle")
