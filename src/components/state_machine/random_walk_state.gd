class_name RandomWalkState
extends ActorState

@export var speed: float = 250.0
@export var acceleration: float = 2000.0

@export_group("Random Walk Parameters")
@export var bounds: Rect2
@export var min_wait_time: float = 1.0
@export var max_wait_time: float = 3.0
@export var arrival_tolerance: float = 15.0
@export var random_range: float = 250.0

var is_waiting: bool = false
var wait_timer: float = 0.0

func _on_enter_state(params: Dictionary = {}):
	super(params)
	
	# TODO do this better
	bounds = get_tree().current_scene.level_size
	
	_pick_new_target()


func _physics_process(delta: float) -> void:
	super(delta)
	
	if is_waiting:
		wait_timer -= delta
		actor.decelerate(delta)
		actor.move_and_slide()
		
		if wait_timer <= 0.0:
			_pick_new_target()
		return
		
	var distance_to_target = actor.global_position.distance_to(actor.navigation_target)
	
	if distance_to_target <= arrival_tolerance:
		_start_waiting()
	else:
		var nav = actor.get_navigation_vector()
		actor.decelerate(delta)
		actor.velocity = actor.velocity.move_toward(nav * speed, acceleration)
		actor.move_and_slide()


func _pick_new_target() -> void:
	is_waiting = false
	actor.navigation_enabled = true
	
	var point = _get_random_point()
	actor.navigation_target = point


func _get_random_point() -> Vector2:
	var limit = 20
	var point: Vector2 = Vector2.INF
	while limit > 0:
		point = actor.global_position + Math.get_random_point_radial(random_range)
		if bounds.has_point(point):
			return point
		limit -= 1
	return actor.global_position


func _start_waiting() -> void:
	is_waiting = true
	actor.navigation_enabled = false
	wait_timer = randf_range(min_wait_time, max_wait_time)


func _on_exit_state():
	super()
