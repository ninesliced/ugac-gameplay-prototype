class_name NavigateState
extends ActorState

@export var speed = 250.0
@export var acceleration = 2000.0

var targets_entity: bool = false
var target_entity: Entity

func _on_enter_state(params: Dictionary = {}):
	super(params)


func _physics_process(delta: float) -> void:
	super(delta)
	
	if targets_entity:
		if is_instance_valid(target_entity):
			actor.navigation_target = target_entity.global_position
		else:
			actor.navigation_enabled = false
	
	var nav = actor.get_navigation_vector()
	
	actor.decelerate(delta)
	actor.velocity = actor.velocity.move_toward(nav * speed, acceleration)
	actor.move_and_slide()


func set_target_position(p_target_position):
	actor.navigation_enabled = true
	actor.navigation_target = p_target_position
	targets_entity = false
	target_entity = null


func set_target_entity(p_target_entity):
	actor.navigation_enabled = true
	actor.navigation_target = p_target_entity.global_position
	targets_entity = true
	target_entity = p_target_entity


func _on_exit_state():
	super()
