class_name WaveSpawner
extends Node2D

signal wave_started
signal finished

var current_wave_index: int = 0
var current_wave

var spawners: Array[EnemySpawner] = []
var active: bool = false

@export var intermission_duration = 5.0

# REMOVEME, to change later to resources or something 
const waves = [
	{
		"amount": 4,
		"delay_min": 5.0,
		"delay_max": 10.0,
	},
	{
		"amount": 10,
		"delay_min": 5.0,
		"delay_max": 10.0,
	},
	{
		"amount": 10,
		"delay_min": 5.0,
		"delay_max": 10.0,
	},
	{
		"amount": 10,
		"delay_min": 5.0,
		"delay_max": 10.0,
	},
	{
		"amount": 10,
		"delay_min": 5.0,
		"delay_max": 10.0,
	},
	{
		"amount": 10,
		"delay_min": 5.0,
		"delay_max": 10.0,
	},
	{
		"amount": 10,
		"delay_min": 5.0,
		"delay_max": 10.0,
	},
	{
		"amount": 10,
		"delay_min": 5.0,
		"delay_max": 10.0,
	},
]


func _ready() -> void:
	for child in get_children():
		if child is EnemySpawner:
			spawners.append(child)


func _process(delta: float) -> void:
	var enemy_count: int = 0
	for spawner in spawners:
		enemy_count += spawner.limit_count
	
	enemy_count += get_tree().get_nodes_in_group("enemy").size()
	
	$"../UI/Control/EnemiesLeft".text = "Enemies left: %d" % [enemy_count]
	
	if active and enemy_count == 0:
		next_wave()


func activate():
	active = true
	set_wave(0)
	start_wave()


func start_wave():
	wave_started.emit()
	
	await get_tree().create_timer(intermission_duration).timeout
	
	for spawner in spawners:
		@warning_ignore("integer_division")
		spawner.limit = int(current_wave["amount"]) / spawners.size()
		spawner.min_time = current_wave["delay_min"]
		spawner.max_time = current_wave["delay_max"]
		spawner.activate()


func next_wave():
	if current_wave_index >= waves.size() - 1:
		finish()
		return
	
	set_wave(current_wave_index + 1)
	start_wave()


func set_wave(index: int):
	current_wave_index = index
	current_wave = waves[current_wave_index]


func finish():
	active = false
	set_wave(0)
