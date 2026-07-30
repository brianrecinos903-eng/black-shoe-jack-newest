@tool
class_name Turbine
extends Area2D

@export_group("Lift")
@export_range(0.0, 200.0, 0.1) var lift_force: float = 80.0
const LIFT_FORCE_SCALE: float = 1000.0
@export var max_upward_speed: float = 1000
@export var falloff_by_height: bool = true
@export var falloff_strength: float = 0.25

@export_group("Collision Zone")
@export_range(1.0, 5000.0, 1.0, "or_greater") var collision_height: float = 600.0:
	set(value):
		collision_height = max(value, 1.0)
		_update_collision_height()
@export var raise_shape_from_base: bool = true

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var _bodies_in_zone: Array[Node2D] = []


func _ready() -> void:
	_update_collision_height()
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	monitoring = true


func _update_collision_height() -> void:
	var shape_node: CollisionShape2D = collision_shape
	if not shape_node:
		shape_node = get_node_or_null("CollisionShape2D")
	if not shape_node or not shape_node.shape:
		return

	var shape: Shape2D = shape_node.shape
	var half: float = collision_height / 2.0

	if shape is RectangleShape2D:
		shape.size.y = collision_height
	elif shape is CapsuleShape2D:
		shape.height = collision_height
	elif shape is CircleShape2D:
		shape.radius = half
	else:
		return

	if raise_shape_from_base:
		shape_node.position.y = -half


func _physics_process(delta: float) -> void:
	for body in _bodies_in_zone:
		if not is_instance_valid(body):
			continue
		var strength := _get_lift_strength(body)
		if body is CharacterBody2D:
			_apply_lift_character(body, strength, delta)
		elif body is RigidBody2D:
			_apply_lift_rigid(body, strength, delta)


func _get_lift_strength(body: Node2D) -> float:
	if not falloff_by_height:
		return 1.0
	var local_y: float = to_local(body.global_position).y
	var t: float = clamp(-local_y / collision_height, 0.0, 1.0)
	return 1.0 - t * falloff_strength


func _apply_lift_character(body: CharacterBody2D, strength: float, delta: float) -> void:
	if body.velocity.y > -max_upward_speed:
		body.velocity.y -= lift_force * LIFT_FORCE_SCALE * strength * delta
		body.velocity.y = max(body.velocity.y, -max_upward_speed)


func _apply_lift_rigid(body: RigidBody2D, strength: float, delta: float) -> void:
	if body.linear_velocity.y > -max_upward_speed:
		body.apply_central_force(Vector2.UP * lift_force * LIFT_FORCE_SCALE * strength * body.mass * 4.0)


func _on_body_entered(body: Node2D) -> void:
	if body not in _bodies_in_zone:
		_bodies_in_zone.append(body)


func _on_body_exited(body: Node2D) -> void:
	_bodies_in_zone.erase(body)
