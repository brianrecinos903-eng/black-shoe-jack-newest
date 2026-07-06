extends Control

@export_file("*.tscn") var game_scene_path: String

func _ready() -> void:
	$CenterContainer/VBoxContainer/PlayButton.pressed.connect(_on_play_button_pressed)
	$CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_button_pressed)


func _on_play_button_pressed() -> void:
	if game_scene_path.is_empty():
		push_error("No game scene path assigned on MainMenu.")
		return

	get_tree().change_scene_to_file(game_scene_path)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
