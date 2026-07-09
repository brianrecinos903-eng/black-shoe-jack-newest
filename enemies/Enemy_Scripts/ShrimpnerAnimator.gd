extends Node2D

@onready var Enemy: CharacterBody2D = get_parent()
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func animate():
	if !Enemy:
		return

	if Enemy.direction > 0:
		scale.x = abs(scale.x)
	elif Enemy.direction < 0:
		scale.x = -abs(scale.x)
	
	var target_Anim: String = "idle"
	
	#if !Enemy.alive:
		#target_Anim = "death"
	
	if Enemy.stunned:
		target_Anim = "stunned"
	
	elif Enemy.leaping:
		target_Anim = "bounce walk"
	
	else:
		target_Anim = "idle"
	
	if target_Anim != sprite.animation:
		sprite.play(target_Anim)

func _process(delta: float) -> void:
	animate()
