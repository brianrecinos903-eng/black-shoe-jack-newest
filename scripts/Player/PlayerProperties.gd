class_name Player extends CharacterBody2D

var GRAVITY: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@export_group("Movement parameters")
@export_subgroup("Horizontal movement")
@export var speed: float = 250.0
@export var speed_mult: float = 1
@export var speed_mult_max: float = 3
@export var speed_mult_incr: float = 0.01
@export var slide_velocity: float = 1000
@export var crouch_collider_scale: float = 0.5
var standing_collider_pos = 25
var crouch_collider_pos = 44
var direction: int = 1
var face_direction: int = 0;
var can_coyote: bool = true

@export_subgroup("Vertical Movement")
@export var jump_velocity: float = -630.0
@export var spring_jump_velocity: Vector2 = Vector2(1000.0, -1000.0)
@export var coyote_time: float =  0.5
@export_range(0.0,2.0) var gravity_scale := 1.0
@export_range(0.0,2.0) var jump_gravity_scale := 0.8
@export_range(0.0,2.0) var fall_gravity_scale := 1.5


@export_subgroup("Bounce settings")
@export var max_bounces: int = 3
var bounces_left: int = max_bounces

@export_group("Gameplay settings")
@export var health: int = 3
var alive: bool = true
var last_checkpoint: Vector2
var is_hurt := false
var can_be_hurt := true

@onready var death_timer: Timer = $DeathTimer
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D
@onready var state_machine: StateMachine = $StateMachine
@onready var collider: CollisionShape2D = $"CollisionShape2D"

func is_wall_infront():
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, Vector2.RIGHT * direction * 5)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)

func crouch_collider():
	collider.scale.y = crouch_collider_scale
	collider.position.y = crouch_collider_pos

func uncrouch_collider():
	collider.position.y = standing_collider_pos
	collider.scale.y = 1

# movement
func accelerate(allow_full: bool = true) -> void:
	if allow_full:
		speed_mult += speed_mult_incr
	if speed_mult > speed_mult_max:
		speed_mult = speed_mult_max

func decelerate() -> void:
	speed_mult -= speed_mult_incr / 2.0

func apply_wallrun() -> void:
	direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.y = -speed * speed_mult
	else:
		velocity.y = move_toward(velocity.y, 0, -speed)
		speed_mult = 1

func apply_horizontal_movement() -> void:
	direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * speed * speed_mult
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		speed_mult = 1

func apply_speed_input() -> void:
	if Input.is_action_pressed("accelerate"):
		accelerate()
	elif speed_mult > 1:
		decelerate()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta * gravity_scale

func apply_fall(delta: float) -> void:
	velocity.y += GRAVITY * delta * fall_gravity_scale

func apply_jump(delta: float) -> void:
	velocity.y += GRAVITY * delta * jump_gravity_scale



func is_falling() -> bool:
	if not is_on_floor() and velocity.y > 0:
		return true
	else:
		return false


func grounded_state_name() -> String:
	return PlayerState.IDLE if direction == 0 else PlayerState.MOVE

# combat 
func take_dmg(amount: int) -> void:
	if can_be_hurt:
		is_hurt = true
		health -= amount
	
func player_touched_enemy(enemy: Node2D) -> void:
	if not enemy.is_in_group("enemy"):
		return
	if state_machine.current_state.name == PlayerState.SLAM or speed_mult > 2:
		enemy.kill()
	elif state_machine.current_state.name == PlayerState.FALL:
		enemy.stun()
		velocity.y = jump_velocity
	

func kill_player() -> void:
	death_timer.start()
	alive = false

func death_timer_end() -> void:
	health = 3
	alive = true
	global_position = last_checkpoint
	state_machine.transition_to(grounded_state_name())

func animate(state_name: String) -> void:
	if direction > 0:
		anim.scale = Vector2(1, 1)
		face_direction = 1
	elif direction < 0:
		anim.scale = Vector2(-1, 1)
		face_direction = -1

	if not alive:
		anim.play("death")
	elif state_name == PlayerState.SLAM:
		anim.play("slam")
	elif state_name == PlayerState.JUMP:
		anim.play("jump")
	elif state_name == PlayerState.IDLE:
		anim.play("idle")
	elif state_name == PlayerState.CROUCH:
		if direction != 0:
			anim.play("crawl")
		else:
			anim.play("crouch")
	else:
		if speed_mult >= 2.9:
			anim.play("rush")
		elif speed_mult > 2:
			anim.play("sprint")
		elif speed_mult > 1:
			anim.play("run")
		else:
			anim.play("walk")
