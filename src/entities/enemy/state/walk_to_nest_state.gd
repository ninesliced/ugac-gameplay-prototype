class_name WalkToNestState
extends NavigateState

@export var follow_speed = 300.0
@export var detect_range = 600.0

@onready var hitbox: Hitbox = $"../../Hitbox"

var enemy: Enemy

func _ready() -> void:
	super()
	
	enemy = actor as Enemy


func _on_enter_state(params: Dictionary = {}):
	super(params)
	
	if hitbox:
		hitbox.enabled = true
	
	hitbox.on_hurtbox_hit.connect(_on_hitbox_hit_hurtbox)


func _physics_process(delta: float) -> void:
	var target = _get_closest_nest()
	if target:
		enemy.navigation_enabled = true
		enemy.navigation_target = target.global_position
	else:
		enemy.navigation_enabled = false
	super(delta)

func _on_exit_state():
	hitbox.on_hurtbox_hit.disconnect(_on_hitbox_hit_hurtbox)


func _get_closest_nest(): 
	var nodes = get_tree().get_nodes_in_group("nest")
	
	var closest = null
	var min_dist = INF
	
	for node in nodes:
		var dist = enemy.global_position.distance_squared_to(node.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = node
	
	return closest


func _on_hitbox_hit_hurtbox(hurtbox: Hurtbox) -> void:
	if hurtbox.owner is Nest:
		state_machine.travel_to("StealEgg", {"nest" = hurtbox.owner as Nest})
