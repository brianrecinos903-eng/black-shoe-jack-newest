extends CharacterBody2D


const speed = 250.0
const jump_velocity = -400.0
var speed_mult = 1
var speed_mult_max = 3
var speed_mult_change = 0.01

var jumping = false
var walking = false
var running = false
var sprinting = false
var rushing = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func animate():
	var velX = velocity.x
	var velY = velocity.y
	if velX != 0:
		if velX > 0:
			anim.scale = Vector2(1,1)
		else:
			anim.scale = Vector2(-1,1)
		if speed_mult == 3: #Rush
			anim.play("run")
			rushing=true
		elif speed_mult > 2.6: #Spring
			anim.play("run")
			sprinting=true
		elif speed_mult > 1.8: #Run
			anim.play("run")
			running=true
		elif speed_mult > 1: #Walk
			anim.play("walk")
			walking=true
	else:
		speed_mult = 1
		anim.play("idle")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		jumping = true

	var direction := Input.get_axis("left", "right") 
	if direction:
		velocity.x = direction * speed * speed_mult
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
	#Speed Up
	if Input.is_action_pressed("accelerate") and speed_mult < speed_mult_max:
		speed_mult+=speed_mult_change
	elif speed_mult > 1:
		speed_mult-=(speed_mult_change/2)
	
	
	animate()

	move_and_slide() #Dont change these
	walking = false
	running = false
	sprinting = false
	rushing = false
	jumping = false
