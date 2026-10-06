class_name FollowPlayerState
extends NavigateState

@export var undetect_range = 800.0

@onready var hitbox: Hitbox = %Hitbox

var enemy: Enemy

var targeted_player: Player

func _ready() -> void:
	super()
	
	enemy = actor as Enemy


func _on_enter_state(params: Dictionary = {}):
	assert(params.has("player") and params["player"] is Player)
	super(params)
	
	targeted_player = params["player"]
	
	if hitbox:
		hitbox.enabled = true


func _physics_process(delta: float) -> void:
	if not is_instance_valid(targeted_player) or not targeted_player.is_targetable:
		state_machine.travel_to(&"Idle")
		return
	
	var dist = targeted_player.global_position.distance_to(enemy.global_position)
	if dist > undetect_range:
		state_machine.travel_to(&"Idle")
	
	enemy.navigation_enabled = true
	enemy.navigation_target = targeted_player.global_position
	
	super(delta)


func _on_exit_state():
	super()
	
	enemy.navigation_enabled = false
