extends enemy

@onready var eye_top: Marker2D = $AnimatedSprite2D/EyeTop
@onready var eye_bottom: Marker2D = $AnimatedSprite2D/EyeBottom
@onready var collision: CollisionShape2D = $CollisionShape2D

enum BarminState { HIDING, POPPING, ACTIVE, DEAD }

@export_group("movement")
@export var hide_cooldown: float = 1.0
@export var idle_time: float = 0.4
@export var max_health: float = 3.0

@export_group("Direction")
@export var detect_radius: float = 220.0
@export var lose_sight_time: float = 2.0
@export var direction_change_min: float = 0.3
@export var direction_change_max: float = 0.9

@export_group("Shooting")
@export var oil_ball_scene: PackedScene
@export var shoot_interval_min: float = 1.2
@export var shoot_interval_max: float = 2.5
@export var fast_ball_speed: float = 260.0
@export var slow_ball_speed: float = 110.0
@export var shot_stagger: float = 0.25

var state: BarminState = BarminState.HIDING
var health: float
var player: Node2D = null

var _direction_timer: float = 0.0
var _shoot_timer: float = 0.0
var _lost_sight_timer: float = 0.0
var _hide_cooldown_timer: float = 0.0
var _hidden_position: Vector2


func _ready() -> void:
	super._ready()  # sets up stunned_timer + connects hitBox.body_entered
	health = max_health
	_hidden_position = global_position
	_enter_hiding()


func _enter_hiding() -> void:
	state = BarminState.HIDING
	velocity = Vector2.ZERO
	global_position = _hidden_position
	_hide_cooldown_timer = hide_cooldown
	anim.play("hiding")


func _pop_out() -> void:
	if state == BarminState.DEAD:
		return
	state = BarminState.POPPING
	anim.play("idle")
	await get_tree().create_timer(idle_time).timeout
	if state == BarminState.DEAD:
		return
	_enter_active()


func _enter_active() -> void:
	state = BarminState.ACTIVE
	anim.play("walk")
	direction = [-1, 1][randi() % 2]
	_direction_timer = randf_range(direction_change_min, direction_change_max)
	_shoot_timer = randf_range(shoot_interval_min, shoot_interval_max)
	_lost_sight_timer = 0.0


func _physics_process(delta: float) -> void:
	Apply_Gravity(delta)
	move_and_slide()
	if state == BarminState.DEAD:
		return

	_find_player()

	if stunned:
		velocity.x = 0.0
		move_and_slide()
		return

	match state:
		BarminState.HIDING:
			velocity.x = 0.0
			if _hide_cooldown_timer > 0.0:
				_hide_cooldown_timer -= delta
			elif player and global_position.distance_to(player.global_position) <= detect_radius:
				_pop_out()
		BarminState.ACTIVE:
			_process_active(delta)
		_:
			velocity.x = 0.0



func _find_player() -> void:
	if player == null or not is_instance_valid(player):
		var players := get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]


func _process_active(delta: float) -> void:
	_direction_timer -= delta
	if _direction_timer <= 0.0 or is_on_wall():
		direction = [-1, 1][randi() % 2]
		_direction_timer = randf_range(direction_change_min, direction_change_max)

	velocity.x = direction * speed
	anim.flip_h = direction < 0

	var in_range := player != null and global_position.distance_to(player.global_position) <= detect_radius

	if in_range:
		_lost_sight_timer = 0.0
		_shoot_timer -= delta
		if _shoot_timer <= 0.0:
			_fire_volley()
			_shoot_timer = randf_range(shoot_interval_min, shoot_interval_max)
	else:
		_lost_sight_timer += delta
		if _lost_sight_timer >= lose_sight_time:
			_hidden_position = global_position
			_enter_hiding()


func _fire_volley() -> void:
	if oil_ball_scene == null or not is_instance_valid(player):
		return
	var eyes := [eye_top, eye_bottom]
	eyes.shuffle()
	for eye in eyes:
		if state != BarminState.ACTIVE or not is_instance_valid(player):
			return
		_spawn_oil_ball(eye)
		await get_tree().create_timer(shot_stagger).timeout


func _spawn_oil_ball(eye: Node2D) -> void:
	var ball := oil_ball_scene.instantiate()
	get_tree().current_scene.add_child(ball)
	ball.global_position = eye.global_position

	var is_fast := randi() % 2 == 0
	var dir := Vector2(direction, 0)

	ball.set("direction", direction)
	ball.set("velocity", dir * (fast_ball_speed if is_fast else slow_ball_speed))


func kill() -> void:
	print("taking damage")
	state = BarminState.DEAD
	velocity = Vector2.ZERO
	queue_free()


# Overrides the base class's hitBox handler (already wired up in super._ready())
func _on_attack_area_body_entered(body: Node2D) -> void:
	if state == BarminState.ACTIVE and not stunned and body.is_in_group("player"):
		if body.has_method("take_dmg"):
			body.take_dmg(attack_Dmg, Helpers.DamageType.ENEMY)
		print("Attacked by: ", name)
