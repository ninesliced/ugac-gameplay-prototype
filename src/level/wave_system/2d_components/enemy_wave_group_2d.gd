class_name EnemyWaveGroup2D
extends Node2D


@export var data: EnemyWaveGroupData = null


func parse_children() -> EnemyWaveGroupData:
	if not data:
		data = EnemyWaveGroupData.new()
	data.build_enemy_cache_from(self)
	return data
