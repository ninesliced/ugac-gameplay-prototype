class_name Arena2D
extends Node2D


signal cleared
signal wave_cleared
signal wave_started

var _current_wave: EnemyWaveData = null
var _remaining_waves: Array[EnemyWaveData] = []
var _cached_waves: Array[EnemyWaveData] = []


func _ready() -> void:
	_parse_children()
	start()


func start() -> void:
	_current_wave = null
	_remaining_waves = _cached_waves.duplicate()
	
	for wave: EnemyWaveData in _remaining_waves:
		for group: EnemyWaveGroupData in wave.cached_groups:
			if not group.add_enemy_requested.is_connected(add_child):
				group.add_enemy_requested.connect(add_child)
	
	start_next_wave()


func start_next_wave() -> void:
	if not _remaining_waves.is_empty():
		_current_wave = _remaining_waves.pop_front()
		_current_wave.cleared.connect(_on_wave_cleared, CONNECT_ONE_SHOT)
		_current_wave.start(get_tree())
		wave_started.emit()
	else:
		cleared.emit()


func _parse_children() -> void:
	_cached_waves.clear()
	
	for node: Node in get_children():
		if node is EnemyWave2D:
			var wave_node: EnemyWave2D = node
			_cached_waves.append(wave_node.parse_children())
			wave_node.queue_free()


func _on_wave_cleared() -> void:
	wave_cleared.emit()
	start_next_wave()
