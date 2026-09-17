extends EnemyState

@export var follow_speed = 300.0
@export var detect_range = 600.0

@onready var hitbox: Hitbox = $"../../Hitbox"

const accel = 2000.0 

func _ready() -> void:
	super()


func _on_enter_state(params: Dictionary = {}):
	super(params)
	
	if hitbox:
		hitbox.enabled = true
	
	hitbox.on_hurtbox_hit.connect(_on_hitbox_hit_hurtbox)


func _physics_process(delta: float) -> void:
	enemy.decelerate(delta)
	
	var target = _get_closest_nest()
	var target_velocity: Vector2
	if target: # and enemy.global_position.distance_to(target.global_position) < detect_range:
		var dir = enemy.global_position.direction_to(target.global_position)
		target_velocity = dir * follow_speed
	else:
		target_velocity = Vector2.ZERO
	
	enemy.velocity = enemy.velocity.move_toward(target_velocity, accel * delta)
	enemy.move_and_slide()


func _on_exit_state():
	hitbox.on_hurtbox_hit.disconnect(_on_hitbox_hit_hurtbox)


func _get_closest_nest(): 
	var nodes
	if enemy.targets_players:
		nodes = get_tree().get_nodes_in_group("player")
	else:
		nodes = get_tree().get_nodes_in_group("nest")
	
	var closest = null
	var min_dist = INF
	
	for node in nodes:
		var dist = enemy.global_position.distance_squared_to(node.global_position)
		if enemy.targets_players:
			if (node as Player).state_machine.current_state_name != "Fainted":
				if dist < min_dist:
					min_dist = dist
					closest = node
		else:
			if dist < min_dist:
				min_dist = dist
				closest = node
	
	return closest


func _on_hitbox_hit_hurtbox(hurtbox: Hurtbox) -> void:
	if hurtbox.owner is Nest and not enemy.targets_players:
		state_machine.travel_to("StealEgg", {"nest" = hurtbox.owner as Nest})
