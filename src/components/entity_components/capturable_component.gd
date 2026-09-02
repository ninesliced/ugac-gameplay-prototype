class_name CapturableComponent
extends EntityComponent

signal entered_capture(capturer: Entity)
signal exited_capture()

var capturer: Entity

func _ready() -> void:
	super()


func activate(new_capturer: Entity):
	assert(new_capturer, "new_capturer is undefined")
	assert(new_capturer.has_component("CapturerComponent"), "new_capturer has no CapturerComponent")
	
	active = true
	capturer = new_capturer
	entity.set_physics_process(false)
	
	entered_capture.emit(capturer)


func deactivate(direction: Vector2):
	active = false
	entity.set_physics_process(true)
	
	exited_capture.emit(direction)
	capturer = null


func _physics_process(_delta: float) -> void:
	if not active:
		return
	
	entity.global_position = capturer.global_position
