class_name EnemyState extends State 

const WALK = "Walk" 
const STUNNED = "Stunned" 
const DEATH = "Death"

# Called when the node enters the scene tree for the first time.
func _ready() -> void: 
	await owner.ready
	state_owner = owner as enemy 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
