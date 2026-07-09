extends CharacterBody2D

class_name enemy

var stunned_timer: Timer
@export var anim: AnimatedSprite2D

var direction:int = 1
@export var speed:int
@export var attack_Dmg: int
var can_Die: bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var stunned = false

func _ready() -> void:
	stunned_timer = Timer.new()
	stunned_timer.wait_time = 2.0
	stunned_timer.one_shot = true
	add_child(stunned_timer)
	stunned_timer.timeout.connect(_on_skip_move_timer_timeout)

func Apply_Gravity(_delta):
	if !is_on_floor():
		velocity.y += gravity * _delta

func _on_skip_move_timer_timeout() -> void:
	stunned = false

func kill():
	queue_free()

func stun():
	stunned = true
	stunned_timer.start()

func switch_dir():
	direction *= -1
	if velocity.x != 0:
		velocity.x = direction * speed
