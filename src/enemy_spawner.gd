class_name EnemySpawner
extends Node2D

const ENEMY = preload("uid://b1dkuou1ki3ra")

@export var max_time = 15.0

@export var limit = 5
var time = 0.0


func _ready() -> void:
	time = 0.0


func _process(delta: float) -> void:
	time -= delta
	if time <= 0 and limit > 0:
		time += max_time
		limit -= 1
		
		var enemy: Enemy = ENEMY.instantiate()
		enemy.global_position = global_position
		enemy.spawn_node = self
		
		get_parent().add_child(enemy)
