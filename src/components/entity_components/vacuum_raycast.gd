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
	
	if not is_instance_valid(targeted_entity) or not is_instance_valid(targeted_hurtbox):
		_set_target(null, null)
	
	if not is_colliding():
		_set_target(null, null)
		return
	
	var coll = get_collider()
	var coll_pos = get_collision_point()
	if coll is VacuumHurtbox:
		var coll_owner = coll.owner
		if coll_owner is Entity and entity != coll_owner:
			_set_target(coll_owner, coll, coll_pos)


func _set_length(new_len: float):
	length = new_len
	_update_target()


func _set_angle(angle_: float):
	angle = angle_
	_update_target()


func get_direction():
	return target_position.normalized()


func _update_target():
	target_position = (Vector2.RIGHT * length).rotated(angle)


func _set_target(new_entity: Entity, new_hurtbox: VacuumHurtbox, target_pos: Vector2 = target_position) -> void:
	if new_entity == entity:
		return
	if new_hurtbox == targeted_hurtbox:
		return
	
	if targeted_hurtbox:
		targeted_hurtbox._ray_exited(self)
	
	targeted_entity = new_entity
	targeted_hurtbox = new_hurtbox
	if new_hurtbox:
		new_hurtbox._ray_entered(self, target_pos)
