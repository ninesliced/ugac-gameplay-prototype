class_name EnemyWaveData
extends Resource


## Emitted when all of this wave's groups are cleared.
signal cleared

## The amount of before this wave actually starts.
@export_range(0.0, 2.0, 0.1, "or_greater") var start_delay: float = 0.0

@export var cached_groups: Array[EnemyWaveGroupData] = []

var _remaining_groups: int = 0


func start(scene_tree: SceneTree) -> void:
	_remaining_groups = 0
	
	if is_instance_valid(scene_tree) and start_delay > 0.0:
		await scene_tree.create_timer(start_delay, false).timeout
	
	for group: EnemyWaveGroupData in cached_groups:
		group.cleared.connect(_on_group_cleared, CONNECT_ONE_SHOT)
		group.start(scene_tree)
		_remaining_groups += 1
	
	if _remaining_groups < 1:
		cleared.emit()


func build_enemy_group_cache_from(wave_node: EnemyWave2D) -> void:
	cached_groups.clear()
	for node: Node in wave_node.get_children():
		if node is EnemyWaveGroup2D:
			var group_node: EnemyWaveGroup2D = node
			cached_groups.append(group_node.parse_children())


func _on_group_cleared() -> void:
	_remaining_groups -= 1
	if _remaining_groups < 1:
		cleared.emit()
