class_name CapturerComponent
extends EntityComponent

signal captured(new_captured_entity: Entity)
signal uncaptured(direction: Vector2)

var captured_entity: Entity = null: 
	set(val):
		captured_entity = val 

func _ready() -> void:
	super()


func capture(new_captured_entity: Entity, hide_entity: bool = true):
	assert(new_captured_entity, "new_captured_entity is undefined")
	
	captured_entity = new_captured_entity
	captured_entity.capture_from(entity, hide_entity)
	captured.emit(new_captured_entity)


func uncapture(direction: Vector2) -> void:
	captured_entity.uncapture(direction)
	
	captured_entity = null
	uncaptured.emit(direction)


func has_captured_entity() -> bool:
	return captured_entity != null
