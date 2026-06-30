class_name Player extends CharacterBody2D

var health: int = 3
var alive: bool = true
var last_checkpoint: Vector2

const speed: float = 250.0
const jump_velocity: float = -630.0

var speed_mult: float = 1
var speed_mult_max: float = 3
var speed_mult_incr: float = 0.01

var direction: int = 1
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var max_bounces: int = 3
var bounces_left: int = max_bounces

@onready var death_timer: Timer = $DeathTimer
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D
@onready var state_machine: StateMachine = $StateMachine

func accelerate(allow_full: bool = true) -> void:
	if allow_full:
		speed_mult += speed_mult_incr
	if speed_mult > speed_mult_max:
		speed_mult = speed_mult_max

func decelerate() -> void:
	speed_mult -= speed_mult_incr / 2.0

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
		velocity.y += gravity * delta

func take_dmg(amount: int) -> void:
	health -= amount
	if health <= 0:
		kill_player()
	

func grounded_state_name() -> String:
	return "Idle" if direction == 0 else "Move"


func player_touched_enemy(enemy: Node2D) -> void:
	if not enemy.is_in_group("enemy"):
		return
	if state_machine.current_state.name == "Slam" or speed_mult > 2:
		enemy.kill()
	elif state_machine.current_state.name == "Jump":
		enemy.stun()
		velocity.y = jump_velocity

func kill_player() -> void:
	death_timer.start()
	alive = false
	state_machine.transition_to("Death")

func death_timer_end() -> void:
	health = 3
	alive = true
	global_position = last_checkpoint
	state_machine.transition_to(grounded_state_name())

func animate(state_name: String) -> void:
	if direction > 0:
		anim.scale = Vector2(1, 1)
	elif direction < 0:
		anim.scale = Vector2(-1, 1)

	if not alive:
		anim.play("death")
	elif state_name == "Slam":
		anim.play("slam")
	elif state_name == "Jump":
		anim.play("jump")
	elif state_name == "Idle":
		anim.play("idle")
	else:
		if speed_mult >= 2.9:
			anim.play("rush")
		elif speed_mult > 2:
			anim.play("sprint")
		elif speed_mult > 1:
			anim.play("run")
		else:
			anim.play("walk")
