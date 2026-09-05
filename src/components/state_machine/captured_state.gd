class_name CapturedState
extends EntityState

@export var capturable_component: CapturableComponent
@export var state_on_uncapture: StringName
@export var hitbox: Hitbox

func _ready() -> void:
	capturable_component.exited_capture.connect(_on_capturable_component_exited_capture)
	super()


func _on_enter_state(params: Dictionary = {}):
	super(params)
	assert(capturable_component, "capturable_component is undefined")
	assert(params.has("capturer") and params["capturer"], "Entered state without capturer param")
	assert(params["capturer"] is Entity, "capturer is not Entity")
	assert(params["capturer"].has_component("CapturerComponent"), "capturer has no CapturerComponent")
	
	var hide_entity_when_captured = params.get("hide_entity_when_captured", true)
	params["capturer"].get_component("CapturerComponent").capture(entity, hide_entity_when_captured)
	
	if hitbox:
		hitbox.enabled = false


func _on_exit_state():
	super()
	entity.show()


func _physics_process(delta: float) -> void:
	super(delta)


func _on_capturable_component_exited_capture(direction: Vector2):
	state_machine.travel_to(state_on_uncapture, {
		"direction": direction
	})
