class_name CapturerComponent
extends EntityComponent

signal captured(new_captured_entity: Entity)
signal uncaptured(direction: Vector2)

var captured_entity: Entity = null

func _ready() -> void:
	super()

func capture(new_captured_entity: Entity):
	assert(new_captured_entity, "new_captured_entity is undefined")
	assert(new_captured_entity.has_component("CapturableComponent"), "new_capturer has no CapturableComponent")
	
	captured_entity = new_captured_entity
	captured_entity.get_component("CapturableComponent").activate(entity)
	captured.emit(new_captured_entity)

func uncapture(direction: Vector2) -> void:
	assert(captured_entity.has_component("CapturableComponent"), "new_capturer has no CapturableComponent")
	
	captured_entity.get_component("CapturableComponent").deactivate(direction)
	captured_entity = null
	uncaptured.emit(direction)

func has_captured_entity() -> bool:
	return captured_entity != null
