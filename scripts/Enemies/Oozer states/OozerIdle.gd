extends OozerState

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_name = OozerState.IDLE


func enter(): 
	state_owner.speed = 0.0
	#(state_owner as enemy).anim.play(state_name)

func exit():
	pass
