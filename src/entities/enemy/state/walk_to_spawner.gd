extends EnemyState

@export var follow_speed = 300.0
@export var detect_range = 600.0

@onready var capturer_component: CapturerComponent = $"../../CapturerComponent"

const accel = 2000.0 

var target: Node2D
const return_distance: float = 64.0

func _ready() -> void:
	super()


func _on_enter_state(params: Dictionary = {}):
	super(params)
	target = _get_closest_nest()


func _physics_process(delta: float) -> void:
	super(delta)
	
	var target_velocity: Vector2
	if target: # and enemy.global_position.distance_to(target.global_position) < detect_range:
		var dir = enemy.global_position.direction_to(target.global_position)
		target_velocity = dir * follow_speed
		
		if enemy.global_position.distance_to(target.global_position) <= return_distance:
			if capturer_component.captured_entity:
				capturer_component.captured_entity.queue_free()
			enemy.queue_free()
	else:
		target_velocity = Vector2.ZERO
	
	
	enemy.velocity = enemy.velocity.move_toward(target_velocity, accel * delta)
	enemy.move_and_slide()


func _get_closest_nest(): 
	var nodes = get_tree().get_nodes_in_group("spawner")
	
	var closest = null
	var min_dist = INF
	
	for node in nodes:
		var dist = enemy.global_position.distance_squared_to(node.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = node
	
	return closest
