extends enemy

func _init():
	speed = 300
	attack_Dmg = 2
	can_Die = true

func cragoon_base_movement():
	if is_on_wall():
		switch_dir()
	velocity.x = direction * speed

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") && !stunned:
		body.take_dmg(attack_Dmg)
		print("Attacked by: ", name)

func _physics_process(_delta: float) -> void:
	if stunned:
		return
	else:
		cragoon_base_movement()
	move_and_slide()
	Apply_Gravity(_delta)
