extends Node
class_name Saveable


# In order to use this class, make a new child node
# under the component that needs to have variables saved. 
# Set the save ID to something unique (example, for player, use player)
# Increase the array in the inspector and increase the size to what you need.
# what you put there must match EXACTLY the name of the variables you want to save.
# Call save_manager.save_game() to save. We need to keep the save slot # floating around.
@export var save_id: String = ""
@export var target_node_path: NodePath = ^".."
@export var properties_to_save: Array[StringName] = []


func _ready() -> void:
	add_to_group("saveable")


func get_target_node() -> Node:
	var target := get_node_or_null(target_node_path)

	if target == null:
		return get_parent()

	return target


func get_save_data() -> Dictionary:
	var target := get_target_node()
	var data: Dictionary = {}

	if target == null:
		push_warning("Saveable has no valid target: " + str(get_path()))
		return data

	if target.has_method("before_save"):
		target.before_save()

	for property_name in properties_to_save:
		data[String(property_name)] = target.get(property_name)

	return data


func load_save_data(data: Dictionary) -> void:
	var target := get_target_node()

	if target == null:
		push_warning("Saveable has no valid target: " + str(get_path()))
		return

	for property_name in properties_to_save:
		var key := String(property_name)

		if data.has(key):
			target.set(property_name, data[key])

	if target.has_method("after_load"):
		target.after_load()
