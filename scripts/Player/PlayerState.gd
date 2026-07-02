class_name PlayerState extends State

const IDLE = "Idle"
const MOVE = "Move"
const JUMP = "Jump"
const SLAM = "Slam"
const DEATH = "Death"
const FALL = "Fall"
const SPRING = "Spring"
const HURT = "Hurt"


@export var player: Player


func _ready() -> void:
	await owner.ready
	player = owner as Player
	print(owner)
	assert(player != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")
