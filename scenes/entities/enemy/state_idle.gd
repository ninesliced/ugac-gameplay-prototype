extends EnemyState

@export var hitbox: Hitbox

@export var follow_speed = 300.0
@export var detect_range = 600.0

const accel = 2000.0 

var aiming_nest = true

func _ready() -> void:
	super()

func _on_enter_state(params: Dictionary = {}):
	super(params)
	
	if hitbox:
		hitbox.enabled = true

func _physics_process(delta: float) -> void:
	super(delta)
	
	var target = _get_target()
	var target_velocity: Vector2
	if target: # and enemy.global_position.distance_to(target.global_position) < detect_range:
		var dir = enemy.global_position.direction_to(target.global_position)
		target_velocity = dir * follow_speed
	else:
		target_velocity = Vector2.ZERO
		
	enemy.velocity = enemy.velocity.move_toward(target_velocity, accel * delta)
	enemy.move_and_slide()


func _get_closest_player(): 
	_get_closest_in_group("player")


func _get_closest_nest(): 
	_get_closest_in_group("nest")


func _get_closest_in_group(group_name) -> Node2D:
	var nodes = get_tree().get_nodes_in_group(group_name)
	return _get_closest_node_in_array(nodes)


func _get_target():
	#if aiming_nest:
	return _get_closest_nest()
		


func _get_closest_node_in_array(nodes) -> Node2D:
	var closest = null
	var min_dist = INF
	
	for node in nodes:
		var dist = enemy.global_position.distance_squared_to(node.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = node
	
	return closest
