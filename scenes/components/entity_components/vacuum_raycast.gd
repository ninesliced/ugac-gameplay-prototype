class_name VacuumRaycast
extends RayCast2D

var length: float = 64.0: set = _set_length
var direction: float = 0.0: set = _set_direction


func _physics_process(delta: float) -> void:
	if not enabled:
		return
	if not is_colliding():
		return
	
	var coll = get_collider()
	if coll is Hurtbox:
		var par = coll.get_parent()
		if par is Entity and par.has_component("VacuumableComponent"):
			var comp: VacuumableComponent = par.get_component("VacuumableComponent")
			comp.enter_vacuumed_state(get_parent(), self)


func _set_length(len: float):
	length = len
	_update_target()

func _set_direction(angle: float):
	direction = angle
	_update_target()

func _update_target():
	target_position = (Vector2.RIGHT * length).rotated(direction)
