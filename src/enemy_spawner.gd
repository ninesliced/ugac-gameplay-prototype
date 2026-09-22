class_name EnemySpawner
extends Node2D

#const ENEMY = preload("uid://b1dkuou1ki3ra")
const ENEMY = preload("uid://hymh7rw1w80d")

@export var min_time = 20.0
@export var max_time = 35.0
var time = 0.0

@export var limit: int = 20
var limit_count: int = 0

var active = false

func _ready() -> void:
	modulate = Color(0.5, 0.5, 0.5)


func activate() -> void:
	active = true
	time = randf_range(0.0, max_time)
	modulate = Color.WHITE
	limit_count = limit


func _process(delta: float) -> void:
	if not active:
		return
	
	time -= delta
	if time <= 0 and limit_count > 0:
		var t = randf_range(min_time, max_time)
		time += t
		limit_count -= 1
		
		var enemy: Enemy = ENEMY.instantiate()
		enemy.global_position = global_position
		enemy.spawn_node = self
		
		get_parent().add_child(enemy)
