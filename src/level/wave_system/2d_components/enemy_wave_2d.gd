class_name EnemyWave2D
extends Node2D


@export var data: EnemyWaveData = null


func parse_children() -> EnemyWaveData:
	if not data:
		data = EnemyWaveData.new()
	data.build_enemy_group_cache_from(self)
	return data
