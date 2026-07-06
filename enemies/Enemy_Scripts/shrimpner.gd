extends enemy

var jump_Strength: float = -450.0
var player_Found: bool = false
var player_Location: Vector2
var leaping: bool = false
var tracking_Player: bool = false
var hit_Player: bool = false
var can_Turn: bool = true
var leap_Counter_Reset: int  = 3
var leap_Counter: int = leap_Counter_Reset


func _init():
	speed = 500
	attack_Dmg = 5

func Leap(xstrength: float, ystrength: float):
	if is_on_floor():
		velocity.y = jump_Strength * ystrength
		velocity.x = speed * direction * xstrength
		leaping = true


func Leap_Attack():
	Leap(0, 1.75)
	player_Found = false

func Leap_Move():
	Leap(1, 1)

func on_Player_Hit(player: Node):
	if player.is_in_group("player"):
		player.take_dmg(attack_Dmg)

func On_Player_Sight(player: Node):
	if player.is_in_group("player"):
		player_Found = true
		player_Location = player.global_position

func Idle_Timer_End():
	if stunned:
		return
	if player_Found:
		Leap_Attack()
	else:
		Leap_Move()

func _physics_process(_delta: float) -> void:
	if tracking_Player:
		var direction_to_target = global_position.direction_to(player_Location)
		velocity = direction_to_target * speed * 2
		
		if global_position.distance_to(player_Location) < 10.0:
			tracking_Player = false
			leaping = false
			velocity = Vector2.ZERO
	else:
		Apply_Gravity(_delta)
	
	if leaping and velocity.x == 0 and not is_on_floor() and velocity.y >= 0:
		if not tracking_Player:
			tracking_Player = true
	
	if is_on_floor() and velocity.y >= 0:
		velocity.x = 0
		can_Turn = true
		tracking_Player = false
		if leaping:
			leaping = false
			leap_Counter -= 1
			if leap_Counter <= 0:
				switch_dir()
				leap_Counter = leap_Counter_Reset
				print("leaps left = ", leap_Counter)
	
	if not is_on_floor() and is_on_wall() and can_Turn:
		switch_dir()
		leap_Counter = leap_Counter_Reset
		can_Turn = false
		tracking_Player = false
	
	move_and_slide()
	
	if is_on_wall() and not can_Turn:
		velocity.x = speed * direction
