extends CharacterBody2D

class_name enemy

@export var stunned_timer: Timer
@export var anim: AnimatedSprite2D

var direction:int = 1
@export var speed:int = 300

var stunned = false

func animate():
	if velocity.x > 0:
		anim.scale = Vector2(1,1)
	else:
		anim.scale = Vector2(-1,1)
	
	if not stunned:
		anim.play("walk")
	else:
		anim.play("stunned")

func kill():
	queue_free()
func stun():
	stunned = true
	stunned_timer.start()

func switch_dir():
	direction*=-1

func enemy_base_movement():
	if is_on_wall():
		switch_dir()
	velocity.x=direction*speed

func _physics_process(_delta: float) -> void:
	enemy_base_movement()
	animate()
	if not stunned:
		move_and_slide()
