## An Actor is a type of Entity that has life and can recieve damage. 
## (i.e. a living Entity) 
class_name Actor
extends Entity

signal queued_death

@export var is_capturable: bool = true
@export var is_vacuumable: bool = true

var capturer_component: CapturerComponent

var navigation_enabled: bool = false
var navigation_target: Vector2

func _ready() -> void:
	super()
	
	for child in get_children():
		if child is CapturerComponent:
			capturer_component = child


func _physics_process(delta: float) -> void:
	pass


func die() -> void:
	queue_free()
	queued_death.emit()


func get_navigation_vector() -> Vector2:
	## TODO replace this with actual navigation 
	if not navigation_enabled:
		return Vector2.ZERO
	return global_position.direction_to(navigation_target)
