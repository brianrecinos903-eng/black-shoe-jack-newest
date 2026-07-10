extends Node
class_name StateMachine

@export var initial_state: State
@export var enable_debug: bool = false
var current_state: State 
var previous_state: String
var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.player = owner
			child.state_machine = self
	Helpers.print_log("Owner: %s" % owner, enable_debug)
	if initial_state:
		previous_state = initial_state.state_name
		current_state = initial_state
	Helpers.print_log("Initial state: %s" % current_state, enable_debug)
	current_state.enter()

func _physics_process(delta: float) -> void:
	Helpers.print_log("physics tick, current state: %s" % current_state, enable_debug)
	current_state.physics_update(delta)
	
func transition_to(new_state: String):
	if not states.has(new_state):
		return
	Helpers.print_log("Moving from state: %s to: %s" % [current_state, states[new_state]], enable_debug)
	previous_state = current_state.state_name
	current_state.exit()
	current_state = states[new_state]
	current_state.enter()

func _unhandled_input(event: InputEvent) -> void:
	current_state.handle_input(event)
