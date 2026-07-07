class_name Player extends CharacterBody2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@export_group("Movement parameters")
@export_subgroup("Horizontal movement")

@export var max_acceleration: float = 3
@export var acceleration_incr: float = 0.01
var speed: float = 250.0
var acceleration: float = 1

@export var slide_velocity: float = 1000
@export var in_crouch_scale: float = 0.5
var standing_collider_pos = 25
var crouch_collider_pos = 44

var move_direction: int = 1
var face_direction: int = 0;

@export_subgroup("Vertical Movement")

@export var jump_power: float = -630.0
@export var walljump_power: float = 300.0
@export var spring_jump_power: Vector2 = Vector2(1000.0, -1000.0)

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
var is_alive: bool = true
var last_checkpoint: Vector2
var is_hurt := false
var can_be_hurt := true
var dmg_source : Helpers.DamageType
var can_be_hurt_by_spike := true

@export_group("Camera Settings")
@export_range(0,1) var slam_shake_factor := 0.5
@export_range(0,1) var hurt_shake_factor := 0.5



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
		acceleration += acceleration_incr
	if acceleration > max_acceleration:
		acceleration = max_acceleration

func decelerate() -> void:
	acceleration -= acceleration_incr / 2.0

func is_falling() -> bool:
	if not is_on_floor() and velocity.y > 0:
		return true
	else:
		return false

func grounded_state_name() -> String:
	return PlayerState.IDLE if move_direction == 0 else PlayerState.MOVE

func apply_horizontal_movement() -> void:
	move_direction = Input.get_axis("left", "right")
	if move_direction != 0:
		velocity.x = move_direction * speed * acceleration
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		acceleration = 1

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
	elif acceleration > 1:
		decelerate()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta * gravity_factor

func take_dmg(amount: int, dmg_type: Helpers.DamageType = Helpers.DamageType.ENEMY) -> void:
	if can_be_hurt:
		is_hurt = true
		dmg_source = dmg_type
		health -= amount
		
func _in_attack_range(body: Node2D) -> void:
	if not body.is_in_group("enemy"):
		return
	if state_machine.current_state.name == PlayerState.SLAM or acceleration > 2:
		body.kill()
	elif state_machine.current_state.name == PlayerState.FALL:
		body.stun()
		velocity.y = jump_power

func anim_move() -> void:
	if acceleration >= 2.9:
		anim.play("rush")
	elif acceleration > 2:
		anim.play("sprint")
	elif acceleration > 1:
		anim.play("run")
	else:
		anim.play("walk")


func _on_slam_area_body_entered(body: Node2D) -> void:
	print("Body slammed")
	if not body.is_in_group("enemy"):
		return
	body.stun(Helpers.PlayerAttackType.SLAM)


	
