class_name PlayerCamera extends Camera2D

@export var trauma: float = 0.0
@export var trauma_power: float = 2.0       
@export var trauma_decay: float = 1.5       
@export var max_offset: Vector2 = Vector2(32, 32)  
@export var max_roll: float = 0.1           
@export var noise_speed: float = 20.0       

var noise := FastNoiseLite.new() if false else null 
var time: float = 0.0

func _ready() -> void:
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 1.0

func _process(delta: float) -> void:
	if trauma > 0.0:
		trauma = max(trauma - trauma_decay * delta, 0.0)
		time += delta * noise_speed
		apply_shake()
	else:
		offset = Vector2.ZERO
		rotation = 0.0

func apply_shake() -> void:
	var amount := pow(trauma, trauma_power)

	var offset_x := max_offset.x * amount * noise.get_noise_2d(time, 0.0)
	var offset_y := max_offset.y * amount * noise.get_noise_2d(0.0, time)
	var roll := max_roll * amount * noise.get_noise_2d(time, time)

	offset = Vector2(offset_x, offset_y)
	rotation = roll

func shake(amount: float) -> void:
	trauma = clamp(trauma + amount, 0.0, 1.0)

func shake_custom(amount: float, decay: float = trauma_decay) -> void:
	trauma_decay = decay
	shake(amount)