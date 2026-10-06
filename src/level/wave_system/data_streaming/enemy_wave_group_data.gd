class_name EnemyWaveGroupData
extends Resource


## Emitted when all of this group's enemies are defeated.
signal cleared
## Emitted when an enemy is instantiated so listeners can add it to the scene tree.
signal add_enemy_requested(enemy: Enemy)

## The amount of time after a wave starts after which this enemy group is called.
@export_range(0.0, 2.0, 0.1, "or_greater") var start_time: float = 0.0
## The amount of time between enemies spawned by this group.
@export_range(0.0, 2.0, 0.1, "or_greater") var spawn_interval: float = 0.2

@export var cached_enemies: Array[PackedEnemy] = []

var _is_spawning: bool = false
var _remaining_enemies: int = 0


func start(scene_tree: SceneTree) -> void:
	_is_spawning = true
	_remaining_enemies = 0
	
	if is_instance_valid(scene_tree) and start_time > 0.0:
		await scene_tree.create_timer(start_time, false).timeout
	
	for packed_enemy: PackedEnemy in cached_enemies:
		var enemy: Enemy = packed_enemy.instantiate()
		enemy.queued_death.connect(_on_enemy_died, CONNECT_ONE_SHOT)
		add_enemy_requested.emit(enemy)
		_remaining_enemies += 1
		
		if is_instance_valid(scene_tree) and spawn_interval > 0.0:
			await scene_tree.create_timer(spawn_interval, false).timeout
	
	_is_spawning = false
	if _remaining_enemies < 1:
		cleared.emit()


func build_enemy_cache_from(group_node: EnemyWaveGroup2D) -> void:
	cached_enemies.clear()
	for node: Node in group_node.get_children():
		if node is Enemy:
			var enemy: Enemy = node
			var packed_enemy: PackedEnemy = PackedEnemy.from_enemy(enemy)
			if packed_enemy:
				cached_enemies.append(packed_enemy)


func _on_enemy_died() -> void:
	_remaining_enemies -= 1
	if _remaining_enemies < 1:
		cleared.emit()
