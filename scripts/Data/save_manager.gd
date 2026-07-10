extends Node

const SAVE_PATHS: Array[String] = [
	"user://save_1.dat",
	"user://save_2.dat",
	"user://save_3.dat"
]

var current_save_slot: int = 0


func set_save_slot(slot: int) -> void:
	if slot < 0 or slot >= SAVE_PATHS.size():
		push_error("Invalid save slot: " + str(slot))
		return

	current_save_slot = slot


func get_save_path(slot: int = current_save_slot) -> String:
	if slot < 0 or slot >= SAVE_PATHS.size():
		push_error("Invalid save slot: " + str(slot))
		return SAVE_PATHS[0]

	return SAVE_PATHS[slot]


func save_game(slot: int = current_save_slot) -> void:
	var save_data: Dictionary = {}

	for saveable in get_tree().get_nodes_in_group("saveable"):
		if not saveable.has_method("get_save_data"):
			continue

		if saveable.save_id.is_empty():
			push_warning("Saveable node has no save_id: " + str(saveable.get_path()))
			continue

		save_data[saveable.save_id] = saveable.get_save_data()

	var file := FileAccess.open(get_save_path(slot), FileAccess.WRITE)

	if file == null:
		push_error("Could not open save file for writing.")
		return

	file.store_var(save_data)
	file.close()

	print("Game saved to slot ", slot + 1)


func load_game(slot: int = current_save_slot) -> void:
	var path := get_save_path(slot)

	if not FileAccess.file_exists(path):
		print("No save file found in slot ", slot + 1)
		return

	var file := FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error("Could not open save file for reading.")
		return

	var save_data = file.get_var()
	file.close()

	if typeof(save_data) != TYPE_DICTIONARY:
		push_error("Save file is invalid.")
		return

	for saveable in get_tree().get_nodes_in_group("saveable"):
		if not saveable.has_method("load_save_data"):
			continue

		if saveable.save_id.is_empty():
			continue

		if save_data.has(saveable.save_id):
			saveable.load_save_data(save_data[saveable.save_id])

	print("Game loaded from slot ", slot + 1)


func delete_save(slot: int = current_save_slot) -> void:
	var path := get_save_path(slot)

	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("Save deleted from slot ", slot + 1)


func save_exists(slot: int = current_save_slot) -> bool:
	return FileAccess.file_exists(get_save_path(slot))
