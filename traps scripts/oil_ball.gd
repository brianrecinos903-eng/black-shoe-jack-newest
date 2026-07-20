extends Area2D

var speed = 200
var direction = 1
var time_existant = 3.5
var rotate_speed = 25

func change_direction(travel_direction):
	if travel_direction == "left":
		direction = -1
	elif travel_direction == "right":
		direction = 1

func _ready() -> void:
	await get_tree().create_timer(time_existant).timeout
	queue_free()


func _physics_process(delta: float) -> void:
	position.x += speed * direction * delta
	rotation += rotate_speed * delta
	


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.take_dmg(1)
		queue_free()
