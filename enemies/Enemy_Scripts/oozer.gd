extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

enum states {
	ACTIVE, STUNNED
} 

signal on_player_bounce

func _ready() -> void:
	anim.play("idle")
