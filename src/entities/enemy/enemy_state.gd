class_name EnemyState
extends ActorState

var enemy: Enemy

func _ready() -> void:
	super()
	enemy = entity as Enemy
