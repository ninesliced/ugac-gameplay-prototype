class_name RegeneratingLifeComponent
extends LifeComponent

@export var regenerate_speed: float = 10.0
@export var amount_per_regeneration: float = 1.0

var _regenerate_timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if life >= max_life:
		_regenerate_timer = 0.0
		return
	
	_regenerate_timer += delta
	if _regenerate_timer >= 1.0:
		_regenerate_timer -= 1.0
		heal(1.0)
