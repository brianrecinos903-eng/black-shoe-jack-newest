extends Node

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

enum DamageType {
	TRAP,
	ENEMY,
}

enum ZoneType {
	AIR = 10,
	WATER = 20
}
	
enum PlayerAttackType {
	DEFAULT,
	SLAM
}

enum CoinType {
	DEFAULT = 100,
	RED = 300,
	BLUE = 400,
	GREEN = 500
}

func print_log(msg: String, flag: bool):
	if flag:
		print(msg)	
