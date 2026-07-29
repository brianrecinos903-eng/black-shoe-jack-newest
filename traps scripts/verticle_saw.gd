extends CharacterBody2D

var can_reverse = true

@export var speed = 500
@export var spin_speed = 5

var direction = 1

func _physics_process(delta: float) -> void:
	velocity.y = speed * direction
	rotation += spin_speed * direction * delta
	
	move_and_slide()
	
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.take_dmg(1)

func _on_reverse_direction_detect_area_entered(area: Area2D) -> void:
	if area.is_in_group("reverse_direction") and can_reverse:
		can_reverse = false
		direction *= -1
		print(direction)
		await get_tree().create_timer(0.2).timeout
		can_reverse = true
