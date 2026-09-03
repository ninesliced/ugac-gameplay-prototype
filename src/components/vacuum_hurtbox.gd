@tool
class_name VacuumHurtbox
extends Hurtbox

## (OPTIONAL) [VacuumedState] to switch to when hit by a [VacuumRaycast].
@export var vacuumed_state: VacuumedState

signal ray_entered(ray: VacuumRaycast, enter_pos: Vector2)
signal ray_exited(ray: VacuumRaycast, enter_pos: Vector2)

const VACUUM_COLLISION_LAYER = 9

func _enter_tree() -> void:
	set_collision_layer_value(VACUUM_COLLISION_LAYER, true)


## Called by [VacuumRaycast] when touching this Hurtbox. 
func _ray_entered(ray: VacuumRaycast, enter_pos: Vector2) -> void:
	ray_entered.emit(ray, enter_pos)
	if vacuumed_state:
		vacuumed_state.state_machine.travel_to(vacuumed_state.name, {
			"vacuum_attract_target": ray.owner,
			"vacuum_attract_raycast": ray
		})


func _ray_exited(ray: VacuumRaycast):
	ray_exited.emit(ray)
	vacuumed_state.on_ray_exited(ray)
