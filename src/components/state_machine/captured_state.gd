class_name CapturedState
extends EntityState

signal entered_capture(capturer: Entity)
signal exited_capture()

@export var capturable_component: CapturableComponent
@export var state_on_uncapture: StringName = &"Ejected"
@export var hitbox: Hitbox

var capturer: Node2D

func _ready() -> void:
	super()
	
	process_mode = Node.PROCESS_MODE_ALWAYS


func _on_enter_state(params: Dictionary = {}):
	super(params)
	assert(capturable_component, "capturable_component is undefined")
	assert(params.has("capturer") and params["capturer"], "Entered state without capturer param")
	assert(params["capturer"] is Entity, "capturer is not Entity")
	assert(params["capturer"].has_component("CapturerComponent"), "capturer has no CapturerComponent")
	
	capturer = params["capturer"]
	
	entity.reparent(capturer)
	entity.position = Vector2.ZERO
	
	var hide_entity = params.get("hide_entity", true)
	if hide_entity:
		entity.hide()
	
	if hitbox:
		hitbox.enabled = false
	
	entity.set_physics_process(false)
	entered_capture.emit(capturer)


func _on_exit_state():
	super()
	
	entity.reparent(entity.get_parent().get_parent(), true)
	
	entity.set_physics_process(true)
	entity.show()
	
	exited_capture.emit()
	capturer = null


func _physics_process(delta: float) -> void:
	super(delta)


func uncapture(direction: Vector2):
	state_machine.travel_to(&"Ejected", {
		"direction": direction
	})
