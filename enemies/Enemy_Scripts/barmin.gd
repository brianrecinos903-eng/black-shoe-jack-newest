extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

enum BarminState { HIDING, IDLE, WALK, DEAD }

@export var speed: float = 40.0
@export var gravity: float = 900.0
@export var hide_time: float = 1.0   
@export var idle_time: float = 0.5    
@export var attack_Dmg: float = 1 

var state: BarminState = BarminState.HIDING
var direction: int = -1                 


func _ready() -> void:
	state = BarminState.HIDING
	anim.play("hiding")
	velocity = Vector2.ZERO
	await get_tree().create_timer(hide_time).timeout
	_enter_idle()


func _enter_idle() -> void:
	if state == BarminState.DEAD:
		return
	state = BarminState.IDLE
	anim.play("idle")
	await get_tree().create_timer(idle_time).timeout
	_enter_walk()


func _enter_walk() -> void:
	if state == BarminState.DEAD:
		return
	state = BarminState.WALK
	anim.play("walk")


func _physics_process(delta: float) -> void:
	if state == BarminState.DEAD:
		return

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0

	if state == BarminState.WALK:
		velocity.x = direction * speed
		anim.flip_h = direction < 0
	else:
		velocity.x = 0.0

	move_and_slide()

	if state == BarminState.WALK:
		_check_wall_turn()
		_check_player_collisions()


func _check_wall_turn() -> void:
	if is_on_wall():
		direction *= -1


func _check_player_collisions() -> void:
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var collider := col.get_collider()
		if collider and collider.is_in_group("player"):
			var normal := col.get_normal()
			if normal.y < -0.5:
				_die(collider)
			else:
				_hurt_player(collider)


func _hurt_player(player: Node) -> void:
	if player.has_method("take_damage"):
		player.take_damage(self)


func _die(player: Node = null) -> void:
	if state == BarminState.DEAD:
		return
	state = BarminState.DEAD
	velocity = Vector2.ZERO
	collision.set_deferred("disabled", true)

	if player and player.has_method("bounce"):
		player.bounce()

	if anim.sprite_frames and anim.sprite_frames.has_animation("dead"):
		anim.play("dead")
		await anim.animation_finished
	else:
		await get_tree().create_timer(0.2).timeout

	queue_free()

func _on_attack_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_dmg(attack_Dmg, Helpers.DamageType.ENEMY)
		print("Attacked by: ", name)
