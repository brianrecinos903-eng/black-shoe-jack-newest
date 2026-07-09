extends AnimatedSprite2D

@onready var Enemy: CharacterBody2D = get_parent()


func animate():
	if !Enemy:
		return
	
	if Enemy.direction > 0:
		flip_h = false
	elif Enemy.direction < 0:
		flip_h = true

	var target_Anim: String = "idle"
	
	#if !Enemy.alive:
		#target_Anim = "death"
	

	if Enemy.stunned:
		target_Anim = "stunned"

	else:
		target_Anim = "walk"

	if target_Anim != animation:
		print("Switching from ", animation, " to ", target_Anim)
		play(target_Anim)

func _process(delta: float) -> void:
	animate()
