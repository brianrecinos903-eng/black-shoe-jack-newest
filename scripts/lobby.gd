extends Node2D

@onready var bar_music_: AudioStreamPlayer = $"Bar music!"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	bar_music_.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
