extends CharacterBody2D


const speed = 250.0
const jump_velocity = -630.0
var speed_mult = 1
var speed_mult_max = 3
var speed_mult_change = 0.01
var slowing = false

var IDLE = false
var JUMP = false
var WALK = false
var RUN = false
var SPRINT = false
var RUSH = false
var SLAM = false

var bounces_left_max = 3
var bounces_left = bounces_left_max
var down_left_to_bounce = 1 
var bounce_direction:int 

var key_press_delay = 0
	
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func animate():
	var velX = velocity.x
	var velY = velocity.y
	if velY!=0 and not SLAM:
		anim.play("jump")
		JUMP = true
	elif velX != 0 and not SLAM:
		if velX > 0:
			anim.scale = Vector2(1,1)
		else:
			anim.scale = Vector2(-1,1)
			 
		if not JUMP:
			if speed_mult >= 2.9: #Rush
				anim.play("rush")
				RUSH=true
			elif speed_mult > 2: #Sprint
				anim.play("sprint")
				SPRINT=true
			elif speed_mult > 1: #Run
				anim.play("run")
				RUN=true
			elif speed_mult == 1: #Walk
				anim.play("walk")
				WALK=true
	elif SLAM:
		pass#ADD SLAM ANIMATION HERE
	else:
		speed_mult = 1
		IDLE = true
		anim.play("idle")

func _physics_process(delta: float) -> void:
	if key_press_delay >= 0:
		key_press_delay-=1
	
	# Add the gravity.
	if not is_on_floor():
		if SLAM:
			down_left_to_bounce = 1
			velocity += get_gravity() * delta * 2
		else:
			velocity += get_gravity() * delta
	if is_on_floor() and SLAM:
		if bounces_left > 0:
			velocity = -1 * get_gravity() * delta * 45
			bounces_left-=1
		else:
			SLAM = false

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		JUMP = true
		
	
	#Move
	var direction: int
	if not SLAM:
		direction = Input.get_axis("left", "right") 
	elif SLAM:
		if Input.get_axis("left", "right") == 0:
			direction = bounce_direction
		else:
			direction = Input.get_axis("left", "right") 
			bounce_direction = direction
	if direction:
		velocity.x = direction * speed * speed_mult
	else:
		velocity.x = move_toward(velocity.x, 0, speed*speed_mult)
	if not SLAM:
		#Speed Up
		if Input.is_action_pressed("accelerate") and speed_mult < speed_mult_max and is_on_floor():
			speed_mult+=speed_mult_change
		elif speed_mult > 1:
			speed_mult-=(speed_mult_change/2)
	
		#Bounce
		if Input.is_action_just_pressed("down") and not is_on_floor():
			if down_left_to_bounce <= 0:
				bounces_left = bounces_left_max
				SLAM = true
				bounce_direction = direction
			elif key_press_delay<=0:
				down_left_to_bounce-=1
				key_press_delay = 1
		elif is_on_floor():
			down_left_to_bounce = 1
	
	animate()
	
	move_and_slide()
	
	WALK = false
	RUN = false
	SPRINT = false
	RUSH = false
	JUMP = false
	IDLE = false
