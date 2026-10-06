@tool
class_name VacuumHurtbox
extends Hurtbox

## (OPTIONAL) [VacuumedState] to switch to when hit by a [VacuumRaycast].
@export var vacuumed_state: VacuumedState

signal ray_entered(ray: VacuumRaycast, enter_pos: Vector2)
signal ray_exited(ray: VacuumRaycast, enter_pos: Vector2)

const VACUUM_COLLISION_LAYER = 9

var active = true

func _enter_tree() -> void:
	collision_layer = 0
	collision_mask = 0
	set_collision_layer_value(VACUUM_COLLISION_LAYER, true)
	
	if Engine.is_editor_hint() and get_parent() is Entity:
		var state_machine = get_parent().get_node_or_null("StateMachine")
		if state_machine:
			for child in state_machine.get_children():
				if child is VacuumedState:
					vacuumed_state = child


## Called by [VacuumRaycast] when touching this Hurtbox. 
func _ray_entered(ray: VacuumRaycast, enter_pos: Vector2) -> void:
	if not active:
		return 
	
	ray_entered.emit(ray, enter_pos)
	if vacuumed_state:
		vacuumed_state.state_machine.travel_to(vacuumed_state.name, {
			"vacuum_attract_target": ray.owner,
			"vacuum_attract_raycast": ray
		})


func _ray_exited(ray: VacuumRaycast):
	ray_exited.emit(ray)
	if vacuumed_state:
		vacuumed_state.on_ray_exited(ray)


func disable():
	active = false
