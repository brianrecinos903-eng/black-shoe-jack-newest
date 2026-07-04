extends Node
class_name StateMachine

@export var initial_state: State
var current_state: State 
var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.player = owner
			child.state_machine = self
	print("States found: ", states.keys())
	print("Owner: ", owner)
	if initial_state:
		current_state = initial_state
	print("Initial state: ", current_state)
	current_state.enter()

func _physics_process(delta: float) -> void:
	print("physics tick, current state: ", current_state)
	current_state.physics_update(delta)
	
func transition_to(new_state: String):
	if not states.has(new_state):
		return
	print("Moving from state: ", current_state, "to: ", states[new_state])
	current_state.exit()
	current_state = states[new_state]
	current_state.enter()

func _unhandled_input(event: InputEvent) -> void:
	current_state.handle_input(event)
