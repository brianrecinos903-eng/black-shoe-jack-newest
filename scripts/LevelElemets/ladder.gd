@tool
extends Area2D
class_name Ladder

@export var climb_speed: float = 220.0
@export_range(128.0, 4096.0, 128.0, "suffix:px") var ladder_height: float = 128.0:
	set(value):
		ladder_height = value
		_update_size()


func _ready() -> void:
	_update_size()


func _update_size() -> void:
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	var climb_area := get_node_or_null("ClimbArea") as CollisionShape2D

	if sprite and sprite.texture:
		sprite.region_rect = Rect2(0, 0, sprite.texture.get_width(), ladder_height)
	if climb_area and climb_area.shape is RectangleShape2D:
		climb_area.shape.size.y = ladder_height


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.enter_ladder(self)


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		body.exit_ladder(self)
