class_name VacuumRaycast
extends RayCast2D

var length: float = 64.0: set = _set_length
var direction: float = 0.0: set = _set_direction


func test(direction):
	pass


func _set_length(len: float):
	length = len
	_update_target()

func _set_direction(angle: float):
	direction = angle
	_update_target()

func _update_target():
	target_position = (Vector2.RIGHT * length).rotated(direction)
