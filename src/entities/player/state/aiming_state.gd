class_name AimingState
extends PlayerState

@onready var visuals: PlayerVisuals = %Visuals

func _ready() -> void:
	super()


func _on_enter_state(params: Dictionary = {}):
	super(params)
	visuals.aim_indicator.show()
	visuals.play("Aiming")


func _physics_process(delta: float) -> void:
	player.decelerate(delta)
	
	visuals.shake(3, 0.1)
	
	if not player.is_action_pressed("game_action"):
		player.exhale()


func _on_exit_state():
	super()
	visuals.aim_indicator.hide()
