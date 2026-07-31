extends Enemy

var direction = 1 
var spd = 10.0

enum states {
	ACTIVE, STUNNED
} 

signal on_player_bounce 

func turn(): 
	direction *= -1
	pass 

func _ready() -> void:
	anim.play("idle")

func _process(delta: float) -> void:
	position.x += spd * direction * delta
