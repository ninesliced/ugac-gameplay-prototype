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
	
	visuals.play("Damaged")
	visuals.shake(10.0, duration)
	visuals.sprite_rotation = 0.0
	
	time = duration


func _process(delta: float) -> void:
	super(delta)
	
	time -= delta
	if time <= 0.0:
		state_machine.travel_to("Inactive")
	
	visuals.sprite_rotation += delta * rotate_speed
	visuals.scale = Vector2.ONE * remap(time, duration, 0.0, 1.0, 0.0)


func _on_exit_state():
	super()
	
	visuals.sprite_rotation = 0.0
	visuals.scale = Vector2.ONE
	visuals.play("RESET")


func _physics_process(delta: float) -> void:
	super(delta)
