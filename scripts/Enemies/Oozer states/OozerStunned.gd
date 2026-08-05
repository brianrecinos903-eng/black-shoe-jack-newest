extends OozerState


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_name = OozerState.STUNNED

func enter():
	state_owner.speed = 0.0 
	state_owner.anim.play("Stunned")

func exit():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
