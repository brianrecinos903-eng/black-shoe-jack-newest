extends CharacterBody2D

var direction:int = 1
var speed = 300

func _physics_process(delta: float) -> void:
	if is_on_wall():
		direction*=-1
	velocity.x=direction*speed
	
	move_and_slide()
