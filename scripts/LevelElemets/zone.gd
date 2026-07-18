extends Area2D
class_name Zone

@export var zone_id: Helpers.ZoneType = Helpers.ZoneType.AIR

@export var target_group: String = "player"

signal player_entered_zone(zone: Zone, player: Node)
signal player_exited_zone(zone: Zone, player: Node)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group(target_group):
		return

	player_entered_zone.emit(self, body)

	if body.has_method("enter_zone"):
		body.enter_zone(zone_id)

func _on_body_exited(body: Node) -> void:
	if not body.is_in_group(target_group):
		return

	player_exited_zone.emit(self, body)

	if body.has_method("exit_zone"):
		body.exit_zone(zone_id)