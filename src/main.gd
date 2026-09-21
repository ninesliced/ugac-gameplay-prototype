extends Node2D

var game_started = false

var spawners = []

func _ready() -> void:
	spawners.clear()
	for spawner in get_tree().get_nodes_in_group("spawner"):
		spawners.append(spawner)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("game_start"):
		start_game()


func _process(delta: float) -> void:
	var n = 0
	for spawner: EnemySpawner in get_tree().get_nodes_in_group("spawner"):
		n += spawner.limit_count


func start_game():
	print("START GAME")
	game_started = true
	
	for player: Player in get_tree().get_nodes_in_group("player"):
		player.life_component.set_life(player.life_component.max_life)
	
	$WaveSpawner.activate()


func _on_button_pressed() -> void:
	for i in 40:
		InputManager.remove_user(i)
	get_tree().reload_current_scene()
