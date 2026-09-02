class_name VacuumHurtbox
extends Hurtbox

const VACUUM_COLLISION_LAYER = 9

func _ready() -> void:
	set_collision_layer_value(VACUUM_COLLISION_LAYER, true)
