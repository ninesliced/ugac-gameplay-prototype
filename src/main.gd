extends Node2D

var game_started = false

var spawners = []

var level_size = Rect2(0, 0, 1920, 1080)

func _ready() -> void:
	spawners.clear()
	for spawner in get_tree().get_nodes_in_group("spawner"):
		spawners.append(spawner)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("game_start") and not game_started:
		start_game()


func _process(delta: float) -> void:
	pass


func start_game():
	print("START GAME")
	game_started = true
	
	for player: Player in get_tree().get_nodes_in_group("player"):
		player.life_component.set_life(player.life_component.max_life)
	
	$Arena.start()
	#$WaveSpawner.activate()


func _on_button_pressed() -> void:
	for i in 40:
		InputManager.remove_user(i)
	get_tree().reload_current_scene()


func get_number_of_fainted_players():
	var n = 0
	for player: Player in get_tree().get_nodes_in_group("player"):
		if player.is_dead:
			n += 1
	return n


func get_fainted_ratio():
	return float(get_number_of_fainted_players()) / float(get_tree().get_nodes_in_group("player").size())
