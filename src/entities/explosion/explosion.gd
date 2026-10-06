class_name Explosion
extends Hitbox

@export var duration: float = 0.3 

@onready var sprite: Sprite2D = $Sprite2D

var timer: float = 0.0

func _ready() -> void:
	super()
	sprite.show()
	
	timer = duration


func _process(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		hide()
		queue_free()
