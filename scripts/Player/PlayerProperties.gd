class_name Player extends CharacterBody2D

signal took_damage(new_health: int)

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@export_group("Movement parameters")
@export_subgroup("Horizontal movement")

@export var max_speed_multiplier: float = 3
@export var speed_multiplier_step: float = 0.01
@export var friction_force: float = 800.0
@export var acceleration = 1000.0
@export var max_speed: float = 600
@export var speed: float 
var speed_multiplier: float = 1

@export var slide_impulse: float = 1000
@export var in_crouch_scale: float = 0.5
var standing_collider_pos = 25
var crouch_collider_pos = 44

var move_direction: int = 1
var face_direction: int = 0

@export_subgroup("Vertical Movement")

@export var jump_impulse: float = -630.0
@export var wall_jump_impulse: float = 300.0
@export var spring_jump_impulse: Vector2 = Vector2(1000.0, -1000.0)

@export var coyote_timeframe: float =  0.5
var can_coyote: bool = true

@export_range(0.0,2.0) var default_gravity_factor := 1.0
@export_range(0.0,2.0) var jump_gravity_factor := 0.8
@export_range(0.0,2.0) var fall_gravity_factor := 1.5
var gravity_factor := 1.0
var inverse_sprite_pos = 50
var default_sprite_pos = 0


@export_subgroup("Bounce settings")
@export var max_bounces: int = 3
var bounces_left: int = max_bounces

@export_group("Gameplay settings")
@export var health: int = 3
@export var dmg_knockback: Vector2 = Vector2(100, 100)
@export var spike_knockback: Vector2 = Vector2(0, -750)
var is_alive: bool = true
var last_checkpoint: Vector2
var is_hurt := false
var can_be_hurt := true
var dmg_source : Helpers.DamageType

@export_group("Camera Settings")
@export_range(0,1) var slam_shake_factor := 0.5
@export_range(0,1) var hurt_shake_factor := 0.5

@export_group("Debug")
@export var enable_debug: bool = false


@onready var death_timer: Timer = $DeathTimer
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_2d: PlayerCamera = $Camera2D
@onready var state_machine: StateMachine = $StateMachine
@onready var collider: CollisionShape2D = $"CollisionShape2D"
@onready var slam_area: CollisionShape2D = $SlamArea/"CollisionShape2D"



func _ready() -> void:
	slam_area.disabled = true

func crouch_collider():
	collider.scale.y = in_crouch_scale
	collider.position.y = crouch_collider_pos

func uncrouch_collider():
	collider.position.y = standing_collider_pos
	collider.scale.y = 1

func is_level_within_distance(dir: Vector2, check_distance: float) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + dir.normalized() * check_distance
	)
	query.exclude = [self]  # ignore the player itself

	var result = space_state.intersect_ray(query)
	return result.size() > 0 


func accelerate(allow_full: bool = true) -> void:
	if allow_full:
		speed_multiplier += speed_multiplier_step
	if speed_multiplier > max_speed_multiplier:
		speed_multiplier = max_speed_multiplier

func decelerate() -> void:
	speed_multiplier -= speed_multiplier_step / 2.0

func is_falling() -> bool:
	if not is_on_floor() and velocity.y > 0:
		return true
	else:
		return false

func grounded_state_name() -> String:
	return PlayerState.IDLE if move_direction == 0 else PlayerState.MOVE

func apply_horizontal_movement(delta: float) -> void:
	move_direction = Input.get_axis("left", "right")
	if move_direction != 0:
		velocity.x = move_toward(velocity.x, move_direction * max_speed, acceleration * speed_multiplier * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction_force * delta * speed_multiplier)
		speed_multiplier = 1
	speed = velocity.x

	if move_direction > 0:
		anim.scale.x = 1
		face_direction = 1
	elif move_direction < 0:
		anim.scale.x = -1
		face_direction = -1
	
	if gravity_factor == -1:
		anim.scale.y = -1
	else: 
		anim.scale.y = 1

	
func apply_speed_input() -> void:
	if Input.is_action_pressed("accelerate"):
		accelerate()
	elif speed_multiplier > 1:
		decelerate()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta * gravity_factor

func take_dmg(amount: int, dmg_type: Helpers.DamageType = Helpers.DamageType.ENEMY) -> void:
	if can_be_hurt:
		is_hurt = true
		dmg_source = dmg_type
		health -= amount
		
		took_damage.emit(health)
		
		
func _in_attack_range(body: Node2D) -> void:
	if not body.is_in_group("enemy"):
		return
	if state_machine.current_state.name == PlayerState.SLAM or speed_multiplier > 2:
		body.kill()
	elif state_machine.current_state.name == PlayerState.FALL:
		body.stun()
		velocity.y = jump_impulse

func anim_move() -> void:
	if speed_multiplier >= 2.9:
		anim.play("rush")
	elif speed_multiplier > 2:
		anim.play("sprint")
	elif speed_multiplier > 1:
		anim.play("run")
	else:
		anim.play("walk")


func _on_slam_area_body_entered(body: Node2D) -> void:
	Helpers.print_log("Body slammed", enable_debug)
	if not body.is_in_group("enemy"):
		return
	body.stun(Helpers.PlayerAttackType.SLAM)
	

func _on_spike_body_entered(body: Node2D) -> void:
	take_dmg(1, Helpers.DamageType.TRAP)
	velocity = spike_knockback
	
	
	
