class_name EnemySpawner
extends Node2D

@export var min_time = 20.0
@export var max_time = 35.0
var time = 0.0

@export var limit: int = 20
var limit_count: int = 0

var active = false

const enemies = {
	Enemies.EGG_STEALER: 5.0,
	Enemies.PLAYER_CHASER: 5.0,
	Enemies.BOMB: 1.0,
}

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
		
		var enemy_to_spawn = Math.get_weighted_random(enemies)
		var enemy: Enemy = enemy_to_spawn.instantiate()
		enemy.global_position = global_position
		
		get_parent().add_child(enemy)
