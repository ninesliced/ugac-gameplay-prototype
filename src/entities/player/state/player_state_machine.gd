extends StateMachine

@onready var capturer_component: CapturerComponent = $"../CapturerComponent"
@onready var visuals: PlayerVisuals = $"../Visuals"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	capturer_component.force_uncaptured.connect(_on_capturer_component_force_uncaptured)


func _on_capturer_component_force_uncaptured():
	visuals.play("Spit")
