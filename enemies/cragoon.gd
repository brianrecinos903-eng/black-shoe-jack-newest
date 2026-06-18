extends CharacterBody2D

class_name enemy

@export var direction:int = 1
@export var speed = 300

func switch_dir():
	direction*=-1

func _physics_process(delta: float) -> void:
	if is_on_wall():
		switch_dir()
	velocity.x=direction*speed
	
	move_and_slide()
