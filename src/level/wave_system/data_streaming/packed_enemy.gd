class_name PackedEnemy
extends Resource


## Custom "packed scene" used to cache enemies with extra data (e.g. initial position, health, etc).

## The scene of the packed enemy.
@export var scene: PackedScene = null
## The initial position of the enemy.
@export_storage var position: Vector2 = Vector2.ZERO


static func from_enemy(p_enemy: Enemy) -> PackedEnemy:
	if ResourceLoader.exists(p_enemy.scene_file_path):
		var packed_enemy: PackedEnemy = PackedEnemy.new()
		packed_enemy.scene = ResourceLoader.load(p_enemy.scene_file_path)
		packed_enemy.position = p_enemy.position
		return packed_enemy
	return null


func instantiate() -> Enemy:
	var enemy: Enemy = scene.instantiate()
	enemy.position = position
	return enemy
