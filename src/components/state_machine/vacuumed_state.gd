class_name VacuumedState
extends EntityState

@export_group("Vacuum Physics")
@export var vacuum_acceleration: float = 1600.0
@export var vacuum_top_speed: float = 6000.0
@export var finish_distance: float = 64.0
@export var lock_inhale_distance: float = 128.0

@export_group("State Transitions & Hitbox")
@export var state_on_finished: StringName
@export var state_on_captured: StringName
@export var hitbox: Hitbox

var target: Node2D = null
var vacuum_raycast: VacuumRaycast = null
var vacuum_speed: float = 0.0

var vaccum_lock: bool = false

func _ready() -> void:
	super()
	assert(state_on_finished, "state_on_finished is undefined")
	assert(state_on_captured, "state_on_captured is undefined")


func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		release()
		return
	
	var direction = entity.global_position.direction_to(target.global_position)
	
	vacuum_speed = min(vacuum_speed + vacuum_acceleration * delta, vacuum_top_speed)
	entity.velocity = direction * vacuum_speed
	
	var dist = entity.global_position.distance_to(target.global_position)
	vaccum_lock = (dist <= lock_inhale_distance)
	
	if dist <= finish_distance:
		# Reached close enough to target
		capture()
	elif (not is_instance_valid(vacuum_raycast) or not vacuum_raycast.enabled) and (not vaccum_lock):
		# Attract area gets disabled
		release()
	else:
		entity.move_and_slide()


func _on_enter_state(params: Dictionary = {}) -> void:
	super(params)
	assert(params.has("vacuum_attract_target") and params["vacuum_attract_target"], "Entered VacuumedState without vacuum_attract_target param")
	assert(params.has("vacuum_attract_raycast") and params["vacuum_attract_raycast"], "Entered VacuumedState without vacuum_attract_raycast param")
	
	target = params["vacuum_attract_target"]
	vacuum_raycast = params["vacuum_attract_raycast"]
	vacuum_speed = 0.0
	
	vaccum_lock = false
	
	if hitbox:
		hitbox.enabled = false
	
	if entity is Actor and entity.capturer_component:
		(entity as Actor).capturer_component.uncapture(Vector2.RIGHT.rotated(randf_range(0, TAU)))


func _on_exit_state() -> void:
	super()
	_clear_vacuum_data()


func capture() -> void:
	var capturer = target
	_clear_vacuum_data()
	
	if capturer is Entity and capturer.has_component("CapturerComponent"):
		var capturer_component: CapturerComponent = capturer.get_component("CapturerComponent")
		capturer_component.capture(entity)


func release() -> void:
	if not is_in_state:
		return
	_clear_vacuum_data()
	state_machine.travel_to(state_on_finished)


func on_ray_exited(ray: VacuumRaycast) -> void:
	if vaccum_lock:
		return
	release()


func _clear_vacuum_data() -> void:
	target = null
	vacuum_raycast = null
	vacuum_speed = 0.0
