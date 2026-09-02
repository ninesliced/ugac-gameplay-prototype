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
		set_state(default_state)


func set_state(name: StringName, params: Dictionary = {}):
	var node = get_node_or_null(str(name))
	assert(node, "Invalid state: '" + str(name) + "'")
	assert(node is AbstractState, "Node '" + str(name) + "' isn't an AbstractState")
	
	if current_state_name == name:
		return
	
	if current_state:
		current_state.is_in_state = false
		current_state.exit_state.emit()
		current_state._on_exit_state()
		current_state.process_mode = Node.PROCESS_MODE_DISABLED
	
	node.process_mode = Node.PROCESS_MODE_INHERIT
	node.is_in_state = true
	node._on_enter_state(params)
	node.enter_state.emit()
	
	current_state_name = name
	current_state = node
