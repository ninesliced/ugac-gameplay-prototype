class_name EnemyState
extends ActorState

var enemy: Enemy

func _ready() -> void:
	super()
	enemy = state_machine.entity as Enemy
