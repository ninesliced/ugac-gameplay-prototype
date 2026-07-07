extends EnemyState

@export var hitbox: Hitbox

@export var follow_speed = 300.0
@export var detect_range = 600.0

func _ready() -> void:
	super()

func _on_enter_state(params: Dictionary = {}):
	super(params)
	
	if hitbox:
		hitbox.enabled = true

func _physics_process(delta: float) -> void:
	super(delta)
	
	var player: Player = _get_closest_player()
	if player and enemy.global_position.distance_to(player.global_position) < detect_range:
		var dir = enemy.global_position.direction_to(player.global_position)
		enemy.velocity = dir * follow_speed
	else: 
		enemy.velocity = Vector2.ZERO
	
	enemy.move_and_slide()

func _get_closest_player(): 
	var players = get_tree().get_nodes_in_group("player")
	var closest_player = null
	var min_dist = INF
	
	for p in players:
		var dist = enemy.global_position.distance_squared_to(p.global_position)
		if dist < min_dist:
			min_dist = dist
			closest_player = p
	
	return closest_player
