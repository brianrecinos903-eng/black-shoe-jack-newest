extends Node

var points: int 
var coins: int
var oil_drums: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	points = 5000;
	coins = 0;
	oil_drums = 0;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print("Points: ", points)
