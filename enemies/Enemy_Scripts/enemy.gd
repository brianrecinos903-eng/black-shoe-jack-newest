extends CharacterBody2D

class_name enemy

var stunned_timer: Timer
@export var anim: AnimatedSprite2D
@onready var hitBox: Area2D = $AttackHitBox

var direction:int = 1
@export var speed:int
@export var attack_Dmg: int
var can_Die: bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var stunned: bool = false

func _ready() -> void:
	stunned_timer = Timer.new()
	stunned_timer.wait_time = 2.0
	stunned_timer.one_shot = true
	add_child(stunned_timer)
	stunned_timer.timeout.connect(_on_stun_timer_timeout)
	hitBox.body_entered.connect(_on_attack_area_body_entered)

func Apply_Gravity(_delta) -> void:
	if !is_on_floor():
		velocity.y += gravity * _delta

func _on_stun_timer_timeout() -> void:
	stunned = false

func kill() -> void:
	queue_free()

func stun(attack_type: Helpers.PlayerAttackType = Helpers.PlayerAttackType.DEFAULT):
	if attack_type == Helpers.PlayerAttackType.SLAM:
		velocity.y = -200
		velocity.x = 0
	stunned = true
	stunned_timer.start()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") && !stunned:
		body.take_dmg(attack_Dmg)

func switch_dir():
	direction *= -1
	if is_on_wall():
		velocity.x = direction * speed
