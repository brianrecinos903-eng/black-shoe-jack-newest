extends OozerState


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_name = OozerState.WALK 

func enter():
	state_owner.speed = 5.0

func exit():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
