extends AnimatedSprite2D

@onready var player: CharacterBody2D = get_parent()

func animate():
	if !player:
		return
	
	if player.direction > 0:
		flip_h = false
	elif player.direction < 0:
		flip_h = true

	var target_Anim: String = "idle"
	
	if !player.alive:
		target_Anim = "death"
	
	elif player.slam_Attack:
		target_Anim = "slam"
	
	elif player.is_Jumping:
		target_Anim = "jump"
	
	elif player.is_Sliding:
		target_Anim = "sliding"
	
	elif player.is_Crouching:
		target_Anim = "crouch"
		
	elif player.direction == 0:
		target_Anim = "idle"
	
	else:
		if player.speed_Mult >= 2.9:
			target_Anim = "rush"
	
		elif player.speed_Mult > 2:
			target_Anim = "sprint"
	
		elif player.speed_Mult > 1:
			target_Anim = "run"
	
		else:
			target_Anim = "walk"
	
	if target_Anim != animation:
		print("Switching from ", animation, " to ", target_Anim)
		play(target_Anim)

func _process(_delta: float) -> void:
	animate()
