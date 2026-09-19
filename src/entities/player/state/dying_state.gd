class_name DyingState
extends PlayerState

@export var duration = 0.6

@onready var visuals: PlayerVisuals = %Visuals

var time = 0.0

const rotate_speed = 3.0

func _ready() -> void:
	super()


func _on_enter_state(params: Dictionary = {}):
	super(params)
	
	visuals.play("Fainted")
	visuals.shake(10.0, duration)
	
	time = duration
	
	player.is_targetable = false
	player.is_dead = true


func _process(delta: float) -> void:
	super(delta)
	
	time -= delta
	if time <= 0.0:
		state_machine.travel_to("Inactive")


func _on_exit_state():
	super()
	
	player.is_targetable = true


func _physics_process(delta: float) -> void:
	super(delta)
