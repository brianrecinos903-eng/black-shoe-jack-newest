extends CharacterBody2D

class_name enemy

@export var stunned_timer: Timer
@export var anim: AnimatedSprite2D

var direction:int = 1
@export var speed:int
@export var attack_Dmg: int
var can_Die: bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var stunned = false

func Apply_Gravity(_delta):
	if !is_on_floor():
		velocity.y += gravity * _delta

func kill():
	queue_free()

func stun(attack_type: Helpers.PlayerAttackType = Helpers.PlayerAttackType.DEFAULT):
	if attack_type == Helpers.PlayerAttackType.SLAM:
		velocity.y = -200
		velocity.x = 0
	stunned = true
	stunned_timer.start()

func switch_dir():
	direction *= -1
	if velocity.x != 0:
		velocity.x = direction * speed
