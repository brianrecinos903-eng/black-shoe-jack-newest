@tool
extends Area2D
class_name Coin

@export_group("Coin settings")
@export var coin_type: Helpers.CoinType = Helpers.CoinType.DEFAULT:
	set(value):
		coin_type = value
		_update_coin_properties()

@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _update_coin_properties():
	if not collider:
		collider = get_node_or_null("CollisionShape2D")
	if not collider:
		return
	if not sprite:
		sprite = get_node_or_null("AnimatedSprite2D")
	if not sprite:
		return

	match coin_type:
		Helpers.CoinType.DEFAULT:
			collider.set("scale", Vector2(1,1))
			sprite.animation = "default"	
			sprite.autoplay = "default"
		Helpers.CoinType.RED:
			collider.set("scale", Vector2(2,2))
			sprite.animation = "red"	
			sprite.autoplay = "red"
		Helpers.CoinType.GREEN:
			collider.set("scale", Vector2(1,1))
			sprite.animation = "green"	
			sprite.autoplay = "green"
		Helpers.CoinType.BLUE:
			collider.set("scale", Vector2(1,1))
			sprite.animation = "blue"	
			sprite.autoplay = "blue"


func _on_body_entered(body: Node2D) -> void:
	if body is Player or body.is_in_group("player") or body.name == "Player":
		body.add_score(coin_type)
		self.queue_free()
