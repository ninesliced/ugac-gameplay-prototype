extends EnemyState

@export var detect_range = 600.0


func _physics_process(delta: float) -> void:
	super(delta)
	
	var candidate = _get_closest_player_in_range()
	if candidate:
		state_machine.travel_to(&"FollowPlayer", {"player": candidate})


func _get_closest_player_in_range():
	var nodes = get_tree().get_nodes_in_group("player")
	
	var closest = null
	var min_dist = INF
	
	for node in nodes:
		var dist_sq = enemy.global_position.distance_squared_to(node.global_position)
		if (node as Player).is_targetable and dist_sq <= detect_range*detect_range:
			if dist_sq < min_dist:
				min_dist = dist_sq
				closest = node
	
	return closest
