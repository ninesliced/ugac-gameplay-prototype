extends AbstractState
class_name StateMachine

@export var default_state: StringName = ""

# dev note: this needs to be an @export in order to be able to be accessed by children states from _ready.
@export var entity: Entity

var _states = []
var current_state_name: StringName
var current_state: AbstractState = null

# TODO change this to use _states, that should be turned into a Dictionary[StringName, AbstractState]

func _ready() -> void:
	var children = get_children()
	_states = children.filter(func(child): return child is AbstractState)
	
	if get_parent() is Entity:
		entity = get_parent()
	
	for state in _states:
		state.process_mode = Node.PROCESS_MODE_DISABLED
	
	if default_state:
		travel_to(default_state)


func travel_to(state_name: StringName, params: Dictionary = {}):
	var node = get_node_or_null(str(state_name))
	assert(node, "Invalid state: '" + str(state_name) + "'")
	assert(node is AbstractState, "Node '" + str(state_name) + "' isn't an AbstractState")
	
	if current_state_name == state_name:
		return
	
	travel_to_state(node, params)


func travel_to_state(state: AbstractState, params: Dictionary = {}) -> void:
	# TODO manage nested states (e.g. nested state machines)
	assert(state is AbstractState, "Node '" + str(name) + "' isn't an AbstractState")
	
	if current_state:
		current_state.is_in_state = false
		current_state.exit_state.emit()
		current_state._on_exit_state()
		current_state.process_mode = Node.PROCESS_MODE_DISABLED
	
	state.process_mode = Node.PROCESS_MODE_INHERIT
	state.is_in_state = true
	state._on_enter_state(params)
	state.enter_state.emit()
	
	current_state_name = state.name
	current_state = state
