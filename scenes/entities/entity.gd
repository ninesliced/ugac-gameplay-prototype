## An Entity is a game object that can move and interact with the world.
class_name Entity
extends CharacterBody2D

@export var deceleration := 1000.0

var captured_entity: Entity
var state_machine: StateMachine

func _ready() -> void:
	var node = get_node_or_null("StateMachine")
	if node and node is StateMachine:
		state_machine = node

func has_component(component_name: StringName) -> bool:
	var node = get_node_or_null(str(component_name))
	return node != null and node is EntityComponent

func get_component(component_name: StringName) -> EntityComponent:
	var node = get_node_or_null(str(component_name))
	assert(node, "Node doesn't exist")
	assert(node is EntityComponent, "Node isn't an EntityComponent")
	
	return node

func knockback_from_entity(entity: Entity, amount: float) -> void:
	var dir = global_position.direction_to(entity.global_position)
	apply_impulse(-dir * amount)

func apply_impulse(vector: Vector2) -> void:
	velocity += vector
