class_name Player extends CharacterBody2D

signal took_damage(new_health: int)

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@export_group("Movement parameters")
@export_subgroup("Horizontal movement")
@export var max_speed_multiplier: float = 3
@export var speed_multiplier_step: float = 0.01
@export var friction_force: float = 800.0
@export var in_water_resistance: float = 1200.0
@export var acceleration = 1000.0
@export var walk_speed: float = 300
@export var max_speed: float = 900
@export var max_wallrun_speed: float = 400
var speed_multiplier: float = 1
@export_subgroup("Slide")
@export var slide_impulse: float = 1000
@export var in_crouch_scale: float = 0.5
var standing_collider_pos = 25
var crouch_collider_pos = 44
# direction
var move_direction: int = 1

@export_subgroup("Vertical Movement")
@export var jump_impulse: float = -630.0
@export var wall_jump_impulse: float = 300.0
@export var spring_jump_impulse: Vector2 = Vector2(1000.0, -1000.0)
@export_subgroup("Coyote time")
@export var coyote_timeframe: float =  0.5
var can_coyote: bool = true
@export_subgroup("Grafvity")
@export_range(0.0,2.0) var default_gravity_factor := 1.0
@export_range(0.0,2.0) var jump_gravity_factor := 0.8
@export_range(0.0,2.0) var fall_gravity_factor := 1.5
@export_range(0.0,2.0) var water_gravity_factor := 0.2
var gravity_factor := 1.0
var inverse_sprite_pos = 50
var default_sprite_pos = 0
var is_on_platform: bool = false

@export_group("Gameplay settings")
@export var max_health: int = 3
@export var health: int = 3
@export var dmg_knockback: Vector2 = Vector2(100, 100)
@export var trap_knockback: Vector2 = Vector2(0, -750)
var in_water: bool = true
var is_alive: bool = true
var last_checkpoint: Vector2
var is_hurt := false
var can_be_hurt := true
var dmg_source : Helpers.DamageType
var is_alive: bool = true
@export_subgroup("Bounce settings")
@export var max_bounces: int = 3
var bounces_left: int = max_bounces

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


var score: float = 0
var in_water: bool = true
var last_checkpoint: Vector2
var active_zones: Dictionary[Helpers.ZoneType, bool] = {}


enum SurfaceType {
	FLOOR,
	CEILLING,
	WALL,
}

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

func apply_motion(delta: float, surface: SurfaceType = SurfaceType.FLOOR) -> void:
	move_direction = Input.get_axis("left", "right")

	var desired_speed = walk_speed
	var wall_run_direction = 0
	match surface:
		SurfaceType.FLOOR, SurfaceType.CEILLING:	
			if speed_multiplier > 1:
				desired_speed = max_speed
			else:
				desired_speed = walk_speed
		SurfaceType.WALL:
			desired_speed = max_wallrun_speed
			if state_machine.previous_state == PlayerState.CEILLING_RUN:
				wall_run_direction = 1
			else:
				wall_run_direction = -1

	if move_direction != 0:
		if surface == SurfaceType.WALL:
			velocity.y = wall_run_direction * max_wallrun_speed * speed_multiplier 
		else:
			velocity.x = move_toward(velocity.x, move_direction * desired_speed, acceleration * speed_multiplier * delta)
	else:
		if in_water:
			velocity.x = move_toward(velocity.x, 0, in_water_resistance * delta * speed_multiplier)
		else:
			velocity.x = move_toward(velocity.x, 0, friction_force * delta * speed_multiplier)
		speed_multiplier = 1

	if move_direction > 0:
		anim.scale.x = 1
	elif move_direction < 0:
		anim.scale.x = -1
	
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

func apply_water_drag(delta: float) -> void:
	velocity.y = move_toward(velocity.y, 0, in_water_resistance * delta * speed_multiplier)

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

func add_score(amount: float):
	score += amount	

func reset_health() -> void:
	health = max_health
	took_damage.emit(health)

func enter_zone(zone_id: Helpers.ZoneType) -> void:
	active_zones[zone_id] = true
	print("Entered zone: ", zone_id)
	# Example: react to specific zones
	match zone_id:
		Helpers.ZoneType.WATER:
			_set_swimming(true)
			return
		Helpers.ZoneType.AIR:
			_set_on_ground(true)
			return

func exit_zone(zone_id: Helpers.ZoneType) -> void:
	active_zones.erase(zone_id)
	print("Exited zone: ", zone_id)
	match zone_id:
		Helpers.ZoneType.WATER:
			_set_swimming(false)
		Helpers.ZoneType.AIR:
			_set_on_ground(false)

func is_in_zone(zone_id: Helpers.ZoneType) -> bool:
	return active_zones.has(zone_id)

func _set_swimming(value: bool) -> void:
	if value:
		gravity_factor = water_gravity_factor
		can_coyote = true
		in_water = true
	else:
		gravity_factor = default_gravity_factor
		in_water = false

func _set_on_ground(value: bool) -> void:
	if value:
		gravity_factor = default_gravity_factor
		in_water = false
	else:
		pass