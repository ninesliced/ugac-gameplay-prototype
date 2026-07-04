@icon("./SplitscreenCamera2D.svg")
class_name SplitscreenCamera2D
extends Camera2D

@export var max_speed: float = 600.0
@export var acceleration: float = 4000.0
@export var slowing_radius: float = 64.0

var target_position: Vector2 = Vector2.ZERO

var _current_velocity: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	var to_target: Vector2 = target_position - global_position
	var distance: float = to_target.length()
	
	if distance < 1.0:
		_current_velocity = Vector2.ZERO
		global_position = target_position
		return
	
	var target_speed: float = max_speed
	if distance < slowing_radius:
		target_speed = max_speed * (distance / slowing_radius)
		
	var desired_velocity: Vector2 = to_target.normalized() * target_speed
	
	_current_velocity = _current_velocity.move_toward(desired_velocity, acceleration * delta)
	global_position += _current_velocity * delta
	
