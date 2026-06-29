extends CharacterBody2D

var health:int = 3
var alive = true
@onready var death_timer: Timer = $DeathTimer

var last_checkpoint:Vector2

const speed = 250.0
const jump_Velocity = -630.0
var speed_Mult = 1
var speed_Mult_Max = 3
var speed_mult_incr = 0.01
var direction: int = 1
var friction = 1200.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_Jumping = false
var slam_Attack = false

var max_Bounces = 3
var bounces_Left = max_Bounces

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D


func accelerate():
	if !slam_Attack:
		speed_Mult += speed_mult_incr 
	if speed_Mult > speed_Mult_Max:
		speed_Mult = speed_Mult_Max

func decelerate():
	speed_Mult -= speed_mult_incr*2

func take_dmg(amount:int):
	health -= amount
	if health <= 0:
		kill_player()

func jump():
	if !is_Jumping && !slam_Attack:
		is_Jumping = true
		velocity.y = jump_Velocity

func slam_start():
	is_Jumping = false
	slam_Attack = true
	speed_Mult = .2
	bounces_Left = max_Bounces

func slam_again():
	if Input.is_action_pressed("down") or bounces_Left == 0:
		slam_Attack = false
		return
	elif bounces_Left > 0:
		velocity.y = jump_Velocity
		bounces_Left -= 1

func player_touched_enemy(enemy: Node2D) -> void:
	if enemy.is_in_group("enemy"):
		if slam_Attack or speed_Mult > 2:
			enemy.kill()
		elif !slam_Attack && is_Jumping:
			enemy.stun()
			velocity.y = jump_Velocity

func kill_player():
	death_timer.start()
	alive = false
	if slam_Attack:
		slam_Attack = false
	

func death_timer_end() -> void:
	health = 3
	alive = true
	self.global_position = last_checkpoint
	
func animate():
	if direction > 0:
			anim.scale = Vector2(1,1)
	elif direction < 0:
		anim.scale = Vector2(-1,1)


	if !alive:
		anim.play("death")
	
	elif slam_Attack:
		anim.play("slam")
	
	elif is_Jumping:
		anim.play("jump")
	
	elif direction == 0:
		anim.play("idle")
	else:
		if speed_Mult >= 2.9:
			anim.play("rush")
		
		elif speed_Mult > 2:
			anim.play("sprint")
		
		elif speed_Mult > 1:
			anim.play("run")
		
		else:
			anim.play("walk")

func _process(_delta) -> void:
	animate()

func _physics_process(_delta: float) -> void:
	
	if is_on_floor():
		is_Jumping = false
	else:
		velocity.y += gravity * _delta
	
	if !alive:
		velocity.x = 0
		move_and_slide()
		return
	
	direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * speed * speed_Mult
	else:
		velocity.x = move_toward(velocity.x, 0, friction * _delta)
	
	if Input.is_action_just_pressed("jump") && is_on_floor():
		jump()
	
	if Input.is_action_pressed("accelerate") && direction != 0:
		accelerate()
	elif speed_Mult > .5:
		decelerate()
	
	if Input.is_action_just_pressed("down") && !is_on_floor() && !slam_Attack:
		slam_start()
	
	if slam_Attack && is_on_floor():
		slam_again()
	
	move_and_slide()
