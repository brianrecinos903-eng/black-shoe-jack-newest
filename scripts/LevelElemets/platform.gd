@tool
extends Node2D
class_name Platform

@export_group("Platform settings")

@export_subgroup("One way collision")
@export var one_way: bool = false:
	set(value):
		one_way = value
		_update_one_way_collision()

@export var one_way_direction: float = 1.0:
	set(value):
		one_way_direction = value
		_update_one_way_collision()

@export_subgroup("Platform interactions")

@export var player_can_drop_down: bool = false:
	set(value):
		player_can_drop_down = value
		_update_drop_down()

@export var moving_platform: bool = false:
	set(value):
		moving_platform = value
		notify_property_list_changed()
		_update_platform_animation()

var animation_name: String = "":
	set(value):
		animation_name = value
		_update_platform_animation()

@export var animation_speed: float = 1.0:
	set(value):
		animation_speed = value
		if animation_player:
			animation_player.speed_scale = value


@onready var animatable_body: AnimatableBody2D = get_node_or_null("AnimatableBody2D")
@onready var animation_player: AnimationPlayer = get_node_or_null("AnimatableBody2D/AnimationPlayer")
@onready var collision_shape: CollisionShape2D = get_node_or_null("AnimatableBody2D/CollisionShape2D")
@onready var pass_through_area: Area2D = get_node_or_null("AnimatableBody2D/Area2D")


func _ready() -> void:
	if not animatable_body:
		animatable_body = get_node_or_null("AnimatableBody2D")
	if not animation_player:
		animation_player = get_node_or_null("AnimatableBody2D/AnimationPlayer")
	if not collision_shape:
		collision_shape = get_node_or_null("AnimatableBody2D/CollisionShape2D")
	if not pass_through_area:
		pass_through_area = get_node_or_null("AnimatableBody2D/Area2D")

	_update_one_way_collision()
	_update_platform_animation()

	if animation_player and not animation_player.animation_list_changed.is_connected(_on_animation_list_changed):
		animation_player.animation_list_changed.connect(_on_animation_list_changed)



func _get_property_list() -> Array[Dictionary]:
	var properties: Array = []

	var anim_player := get_node_or_null("AnimatableBody2D/AnimationPlayer")
	var names := PackedStringArray([""])
	if anim_player:
		for anim in anim_player.get_animation_list():
			names.append(anim)

	properties.append({
		"name": "animation_name",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(names),
		"usage": PROPERTY_USAGE_DEFAULT,
	})

	return properties


func _on_animation_list_changed() -> void:
	notify_property_list_changed()



func _update_one_way_collision() -> void:
	if not collision_shape:
		collision_shape = get_node_or_null("AnimatableBody2D/CollisionShape2D")
	if not collision_shape:
		return

	collision_shape.one_way_collision = one_way
	collision_shape.rotation = 0.0 if one_way_direction >= 0.0 else PI


func _update_platform_animation() -> void:
	if not animation_player:
		animation_player = get_node_or_null("AnimatableBody2D/AnimationPlayer")
	if not animation_player:
		return

	animation_player.speed_scale = animation_speed

	if moving_platform and animation_name != "" and animation_player.has_animation(animation_name):
		if animation_player.current_animation != animation_name or not animation_player.is_playing():
			animation_player.play(animation_name)
	else:
		animation_player.stop()


func _update_drop_down() -> void:
	if not pass_through_area:
		pass_through_area = get_node_or_null("AnimatableBody2D/Area2D")
	if not pass_through_area:
		return

	pass_through_area.monitoring = player_can_drop_down


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("something on platform")
	if body is Player or body.is_in_group("player") or body.name == "Player":
		body.is_on_platform = true



func _on_area_2d_body_exited(body: Node2D) -> void:
	print("something not on platform")
	if body is Player or body.is_in_group("player") or body.name == "Player":
		body.is_on_platform = false
