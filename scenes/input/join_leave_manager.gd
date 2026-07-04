extends Node2D

@export var splitscreen_view: SplitscreenView

var player_tscn: PackedScene = load("res://scenes/entities/player/player.tscn")

signal player_joined(user_index: int)
signal player_left(user_index: int)


func _process(_delta: float) -> void:
	handle_join_leave_input()


func join(device_index: int):
	var user_index = InputManager.add_user(device_index)
	_on_player_join(user_index)
	player_joined.emit(user_index)


func leave(user_index: int):
	if user_index < 0:
		return
	player_left.emit(user_index)
	_delete_player(user_index)
	InputManager.remove_user(user_index)


func handle_join_leave_input():
	for device_index in InputManager.get_all_devices():
		if MultiplayerInput.is_action_just_pressed(device_index, "game_join"):
			if InputManager.is_device_joined(device_index):
				leave(InputManager.get_user_from_device_index(device_index))
			else:
				join(device_index)


func _on_player_join(user_index: int):
	var player = _spawn_player(user_index)
	splitscreen_view.add_cell.call_deferred(player)
	#player.apply_invincibility(PLAYER_SPAWN_INVINCIBILITY)

func _spawn_player(user_index, spawn_position: Vector2 = Vector2.INF) -> Player:
	var player_positions = $PlayerSpawnPositions 
	var player: Player = player_tscn.instantiate()
	player.user_index = user_index
	
	get_parent().add_child(player)
	
	if spawn_position.is_finite():
		player.global_position = spawn_position
	else:
		player.global_position = global_position
	
	InputManager.assign_player_to_user(user_index, player)
	return player


func _delete_player(user_index):
	var player: Player = InputManager.get_player(user_index)
	splitscreen_view.remove_cell_with_target(player)
	
	player.queue_free()
