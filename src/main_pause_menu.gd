extends Control

@onready var remove_players_box: HBoxContainer = %RemovePlayers

var buttons = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	unpause()
	for child in remove_players_box.get_children():
		child.queue_free()
	
	InputManager.user_added.connect(_on_user_added)
	InputManager.user_removed.connect(_on_user_removed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	unpause()


func pause():
	get_tree().paused = true
	show()

func unpause():
	get_tree().paused = false
	hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("game_pause"):
		if not get_tree().paused:
			pause()
		else:
			unpause()


func _on_user_added(user_index: int):
	var button: Button = Button.new()
	button.text = "Remove player %s" % [user_index+1]
	button.pressed.connect(func():
		InputManager.remove_user(user_index)
	)
	remove_players_box.add_child(button)
	buttons.set(user_index, button)


func _on_user_removed(user_index: int):
	var btn = buttons.get(user_index, null)
	if btn:
		buttons.erase(user_index)
		btn.queue_free()


func _on_button_2_pressed() -> void:
	for i in 8:
		InputManager.remove_user(i)
	get_tree().reload_current_scene()
