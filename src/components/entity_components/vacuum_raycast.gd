@tool
class_name VacuumRaycast
extends RayCast2D

var length: float = 64.0: set = _set_length
var angle: float = 0.0: set = _set_angle
var _direction: Vector2 = Vector2.RIGHT

var entity: Entity = null
var targeted_entity: Entity 
var targeted_hurtbox: VacuumHurtbox 

const VACUUM_COLLISION_LAYER = 9


func _enter_tree() -> void:
	set_collision_mask_value(VACUUM_COLLISION_LAYER, true)


func _ready() -> void:
	if Engine.is_editor_hint():
		return 
	
	if owner is Entity:
		entity = owner


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return 
	
	if not enabled:
		return
	if not is_colliding():
		targeted_entity = null
		targeted_hurtbox._ray_exited(self)
		return
	
	var coll = get_collider()
	var coll_pos = get_collision_point()
	if coll is VacuumHurtbox:
		var own = coll.owner
		if own is Entity and entity != own:
			targeted_entity = own
			targeted_hurtbox = coll
			coll._ray_entered(self, coll_pos)


func _set_length(len: float):
	length = len
	_update_target()


func _set_angle(angle_: float):
	angle = angle_
	_update_target()


func get_direction():
	return target_position.normalized()


func _update_target():
	target_position = (Vector2.RIGHT * length).rotated(angle)
