extends CanvasLayer


const CONFIRM_DIALOG_SIZE := Vector2i(760, 360)
@export_file("*.tscn") var main_menu_scene: String = "res://scenes/main_menu.tscn"

@onready var pause_root: Control = $PauseRoot
@onready var resume_button: Button = $PauseRoot/CenterContainer/PanelContainer/VBoxContainer/ResumeButton
@onready var options_button: Button = $PauseRoot/CenterContainer/PanelContainer/VBoxContainer/OptionsButton
@onready var exit_button: Button = $PauseRoot/CenterContainer/PanelContainer/VBoxContainer/ExitButton
@onready var exit_confirm_dialog: ConfirmationDialog = $ExitConfirmDialog


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	pause_root.visible = false
	exit_confirm_dialog.visible = false

	resume_button.pressed.connect(_on_resume_pressed)
	options_button.pressed.connect(_on_options_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	exit_confirm_dialog.confirmed.connect(_on_exit_confirmed)

	exit_confirm_dialog.title = "Exit to Main Menu?"
	exit_confirm_dialog.dialog_text = "Are you sure you want to return to the main menu?"
	var message_label = exit_confirm_dialog.get_label()
	message_label.add_theme_font_size_override("font_size", 34)
	exit_confirm_dialog.get_ok_button().text = "Yup, I'm a wuss."
	exit_confirm_dialog.get_cancel_button().text = "Nah, go back!"
	var ok_button = exit_confirm_dialog.get_ok_button()
	var cancel_button = exit_confirm_dialog.get_cancel_button()
	ok_button.custom_minimum_size = Vector2(280, 72)
	cancel_button.custom_minimum_size = Vector2(280, 72)
	ok_button.custom_minimum_size = Vector2(280, 72)
	cancel_button.custom_minimum_size = Vector2(280, 72)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()

		if exit_confirm_dialog.visible:
			exit_confirm_dialog.hide()
			resume_button.grab_focus()
			return

		if get_tree().paused:
			resume_game()
		else:
			pause_game()


func pause_game() -> void:
	get_tree().paused = true
	pause_root.visible = true
	pause_root.show()
	resume_button.grab_focus()
	print("Game paused. PauseRoot visible: ", pause_root.visible)


func resume_game() -> void:
	get_tree().paused = false
	pause_root.visible = false
	exit_confirm_dialog.hide()
	print("Game resumed.")


func _on_resume_pressed() -> void:
	resume_game()


func _on_options_pressed() -> void:
	print("Options pressed")


func _on_exit_pressed() -> void:
	exit_confirm_dialog.popup_centered(CONFIRM_DIALOG_SIZE)


func _on_exit_confirmed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_scene)
