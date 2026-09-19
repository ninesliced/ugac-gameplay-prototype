## An Actor is a type of Entity that has life and can recieve damage. 
## (i.e. a living Entity) 
class_name Actor
extends Entity

signal queued_death

@export var is_capturable: bool = true
@export var is_vacuumable: bool = true

var capturer_component: CapturerComponent

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
