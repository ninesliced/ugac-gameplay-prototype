extends PlayerState

@export var visuals: PlayerVisuals
@export var duration = 0.25

var time = 0.0

func _ready() -> void:
	super()


func _on_enter_state(params: Dictionary = {}):
	super(params)
	time = duration
	visuals.play("Spit")


func _on_exit_state():
	super()


func _physics_process(delta: float) -> void:
	super(delta)
	
	time -= delta
	if time <= 0.0:
		state_machine.travel_to("Move")
