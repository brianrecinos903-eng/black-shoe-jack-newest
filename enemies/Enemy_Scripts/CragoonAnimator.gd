extends AnimatedSprite2D

@onready var enemy: CharacterBody2D = get_parent()


func animate():
	if !enemy:
		return
	
	if enemy.direction > 0:
		flip_h = false
	elif enemy.direction < 0:
		flip_h = true

	var target_Anim: String = "walk"
	
	#if !enemy.alive:
		#target_Anim = "death"

	if enemy.stunned:
		target_Anim = "stunned"

	else:
		target_Anim = "walk"

	if target_Anim != animation:
		print("Switching from ", animation, " to ", target_Anim)
		play(target_Anim)

func _process(delta: float) -> void:
	animate()
