extends CharacterBody2D

var bounces = 0
var max_bounces = 3
var bounce_strength = 700
var move_direction = 0
var speed = 200
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func set_direction(direction):
	if direction == "left":
		velocity.x = -speed
	
	elif direction == "right":
		velocity.x = speed

func _physics_process(delta):
	velocity.x = move_direction * speed
	velocity.y += gravity * delta

	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()

		if normal.y < -0.7:
			velocity.y = -bounce_strength
			bounces +=1
			if bounces > max_bounces:
				queue_free()

		if abs(normal.x) > 0.7:
			move_direction *= -1


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.take_dmg(1)
