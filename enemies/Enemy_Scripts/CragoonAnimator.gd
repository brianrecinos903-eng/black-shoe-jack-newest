extends AnimatedSprite2D

@onready var enemy: CharacterBody2D = get_parent()


func animate():
	if !enemy:
		return
	
	if enemy.direction > 0:
		flip_h = false
	elif enemy.direction < 0:
		flip_h = true

	var target_Anim: String = "idle"
	
	#if !enemy.alive:
		#target_Anim = "death"
	
	if enemy.leaping:
		target_Anim = "leap"

	elif enemy.stunned:
		target_Anim = "stunned"

	elif !enemy.leaping:
		target_Anim = "idle"

	if target_Anim != animation:
		print("Switching from ", animation, " to ", target_Anim)
		play(target_Anim)

func _process(delta: float) -> void:
	animate()
