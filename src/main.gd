extends Node2D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("game_start"):
		start_game()

func _process(delta: float) -> void:
	pass


func start_game():
	print("START GAME")
