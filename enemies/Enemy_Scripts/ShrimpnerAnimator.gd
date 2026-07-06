extends AnimatedSprite2D

@onready var enemy: CharacterBody2D = get_parent().get_parent()
@onready var container = get_parent()

func animate():
	if !enemy:
		return
	
	var container = get_parent()
	
	if enemy.direction > 0:
		container.scale.x = abs(container.scale.x)
	elif enemy.direction < 0:
		container.scale.x = -abs(container.scale.x)
	
	var target_Anim: String = "idle"
	
	#if !enemy.alive:
		#target_Anim = "death"
	
	if enemy.stunned:
		target_Anim = "stunned"
	
	elif enemy.leaping:
		target_Anim = "bounce walk"
	
	else:
		target_Anim = "idle"
	
	if target_Anim != animation:
		print("Shrimpner switching from ", animation, " to ", target_Anim)
		play(target_Anim)

func _process(delta: float) -> void:
	animate()
