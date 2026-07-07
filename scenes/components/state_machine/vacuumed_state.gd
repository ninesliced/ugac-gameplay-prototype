class_name VacuumedState
extends EntityState

@export var vacuumable_component: VacuumableComponent
@export var state_on_finished: StringName
@export var state_on_captured: StringName
@export var hitbox: Hitbox

func _ready() -> void:
	super()
	assert(vacuumable_component, "vacuumable_component is undefined")
	assert(state_on_finished, "state_on_finished is undefined")
	assert(state_on_captured, "state_on_captured is undefined")
	
	vacuumable_component.finished.connect(_on_vacuumable_component_finished)
	vacuumable_component.finished_captured.connect(_on_vacuumable_component_finished_captured)
	vacuumable_component.finished_uncaptured.connect(_on_vacuumable_component_finished_uncaptured)

func _physics_process(delta: float) -> void:
	super(delta)

func _on_enter_state(params: Dictionary = {}):
	super(params)
	assert(params.has("vacuum_attract_target") and params["vacuum_attract_target"], "Entered VacuumedState without vacuum_attract_target param")
	assert(params.has("vacuum_attract_area") and params["vacuum_attract_target"], "Entered VacuumedState without vacuum_attract_area param")
	
	vacuumable_component.activate(params["vacuum_attract_target"], params["vacuum_attract_area"])
	
	if hitbox:
		hitbox.enabled = false

func _on_exit_state():
	if vacuumable_component.active:
		vacuumable_component.deactivate()

func _on_vacuumable_component_finished():
	pass

func _on_vacuumable_component_finished_captured(capturer: Entity):
	state_machine.set_state(state_on_captured, {"capturer": capturer})

func _on_vacuumable_component_finished_uncaptured():
	state_machine.set_state(state_on_finished)

func finish():
	vacuumable_component.deactivate()
