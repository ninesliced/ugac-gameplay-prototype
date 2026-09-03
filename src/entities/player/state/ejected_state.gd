extends EjectedState


func _physics_process(delta: float) -> void:
	super(delta)
	
	if (entity as Player).is_action_just_pressed("game_dash"):
		state_machine.travel_to("Rolling")
