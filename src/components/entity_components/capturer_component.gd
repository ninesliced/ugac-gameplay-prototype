class_name CapturerComponent
extends EntityComponent

signal captured(new_captured_entity: Entity)
signal uncaptured(direction: Vector2)
signal force_uncaptured()

var captured_entity: Entity = null: 
	set(val):
		captured_entity = val 


func _ready() -> void:
	super()


func _physics_process(delta: float) -> void:
	if captured_entity and captured_entity.state_machine:
		if captured_entity.state_machine.current_state is not CapturedState:
			captured_entity = null
			force_uncaptured.emit()


func capture(new_captured_entity: Entity, hide_entity: bool = true):
	assert(new_captured_entity, "new_captured_entity is undefined")
	
	captured_entity = new_captured_entity
	captured_entity.capture_from(entity, hide_entity)
	captured.emit(new_captured_entity)


func uncapture(direction: Vector2) -> void:
	if not captured_entity:
		return
	
	captured_entity.uncapture(direction)
	
	captured_entity = null
	uncaptured.emit(direction)


func has_captured_entity() -> bool:
	return captured_entity != null
