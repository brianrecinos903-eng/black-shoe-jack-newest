extends Control

@onready var player = get_tree().get_first_node_in_group("player")

@onready var hearts = [
	$Heart1,
	$Heart2,
	$Heart3
]


func _ready():
	player.took_damage.connect(update_health)
	update_health(player.health)


func update_health(current_health):
	for i in hearts.size():
		hearts[i].visible = i < current_health
