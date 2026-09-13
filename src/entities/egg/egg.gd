class_name Egg
extends Actor

var is_nest_mergeable: bool = false
var nest_mergeable_timer: float = 0.1

func _ready() -> void:
	super()
	$Sprite2D.play()
	$Shadow.play()


func _process(delta: float) -> void:
	$Label.text = "" 
	$Label.text += "%s\n" % [name]
	$Label.text += "current_state_name = %s\n" % [state_machine.current_state_name]
	$Label.text += "is_nest_mergeable = %s\n" % [is_nest_mergeable]
	
	nest_mergeable_timer -= delta
	if nest_mergeable_timer <= 0:
		is_nest_mergeable = true
