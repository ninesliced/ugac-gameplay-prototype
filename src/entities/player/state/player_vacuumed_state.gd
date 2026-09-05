class_name PlayerVacuumedState
extends VacuumedState

func _physics_process(_delta: float) -> void:
	if (owner as Player).is_action_just_pressed("game_dash"):
		state_machine.travel_to("Rolling")
