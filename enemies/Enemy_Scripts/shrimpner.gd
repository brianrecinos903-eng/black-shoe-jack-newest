extends enemy

var jump_Strength: float = -450.0
var leaping: bool = false
var can_Turn: bool = true
var leap_Counter_Reset: int  = 3
var leap_Counter: int = leap_Counter_Reset

var player_Location: Vector2
var attacking_Player: bool = false
var hit_Player: bool = false
var is_Leaping_Attack: bool = false

func _init():
	speed = 500
	attack_Dmg = 1

func Leap(xstrength: float, ystrength: float):
	if is_on_floor():
		velocity.y = jump_Strength * ystrength
		velocity.x = speed * direction * xstrength
		leaping = true

func Leap_Attack():
	Leap(0, 1.75)
	is_Leaping_Attack = true

func Leap_Move():
	Leap(1, 1)
	leap_Counter -= 1
	is_Leaping_Attack = false

func Idle_Timer_End():
	if stunned or leaping:
		return
	
	var bodies = $FlipContainer/Sight_Area.get_overlapping_bodies()
	var player_Found: bool = false
	
	for body in bodies:
		if body.is_in_group("player"):
			player_Found = true
			player_Location = body.global_position
			break
	
	if player_Found:
		Leap_Attack()
	else:
		Leap_Move()

func Player_Enter_Hit_Box(player: Node) -> void:
	if player.is_in_group("player"):
		hit_Player = true;

func Player_Left_Hit_Box(player: Node) -> void:
	if player.is_in_group("player"):
		await get_tree().physics_frame
		await get_tree().physics_frame
		hit_Player = false;

func Should_Switch_Direction() -> bool:
	return is_on_floor() and leap_Counter <= 0

func Switch_Direction() -> void:
	switch_dir()
	can_Turn = false
	attacking_Player = false
	leap_Counter = leap_Counter_Reset
	
func Land_From_Leap(attacking: bool) -> void:
	can_Turn = true
	attacking_Player = false
	is_Leaping_Attack = false
	leaping = false
	velocity.x = 0
	player_Location = Vector2.ZERO
	
	if attacking and not hit_Player:
		stun(Helpers.PlayerAttackType.DEFAULT)
	
	if Should_Switch_Direction():
		Switch_Direction()

func _physics_process(_delta: float) -> void:
	if stunned:
		velocity.x = 0
		Apply_Gravity(_delta)
		move_and_slide()
		return
	
	if attacking_Player:
		if is_on_wall():
			Land_From_Leap(is_Leaping_Attack)
		else:
			var direction_to_target = global_position.direction_to(player_Location)
			velocity = direction_to_target * speed * 4
		
		if hit_Player:
			Land_From_Leap(false)
		elif global_position.distance_to(player_Location) <= 10 or is_on_floor():
			if is_on_floor():
				Land_From_Leap(is_Leaping_Attack)
			else:
				attacking_Player = false
	else:
		Apply_Gravity(_delta)
	
	if is_Leaping_Attack and velocity.x == 0 and velocity.y >= 0:
		if not attacking_Player:
			attacking_Player = true
	
	if leaping and is_on_floor():
		if velocity.y >= 0:
			Land_From_Leap(is_Leaping_Attack)
	
	if leaping and is_on_wall() and can_Turn:
		Switch_Direction()
	
	move_and_slide()
