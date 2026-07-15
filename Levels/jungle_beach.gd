extends Node2D

@onready var beach_music: AudioStreamPlayer = $Beach_music

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	beach_music.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
