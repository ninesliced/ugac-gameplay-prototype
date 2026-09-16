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
		n += spawner.limit
	$CanvasLayer/Control/EnemiesLeft.text = "Enemies left: %s" % [n]	


func start_game():
	print("START GAME")
	game_started = true
	
	for spawner in spawners:
		spawner.activate()
	
	for player: Player in get_tree().get_nodes_in_group("player"):
		player.life_component.set_life(player.life_component.max_life)
	
	%StartTutorial.hide()
	$CanvasLayer/Control/EnemiesLeft2.show()
	await get_tree().create_timer(5.0).timeout
	$CanvasLayer/Control/EnemiesLeft2.hide()
	


func _on_button_pressed() -> void:
	for i in 6:
		InputManager.remove_user(i)
	get_tree().reload_current_scene()
