class_name VacuumedState
extends EntityState

@export_group("Vacuum Physics")
@export var vacuum_acceleration: float = 1600.0
@export var vacuum_top_speed: float = 6000.0
@export var finish_distance: float = 64.0

@export_group("State Transitions & Hitbox")
@export var state_on_finished: StringName
@export var state_on_captured: StringName
@export var hitbox: Hitbox

var target: Node2D = null
var vacuum_raycast: VacuumRaycast = null
var vacuum_speed: float = 0.0

func _ready() -> void:
	super()
	assert(state_on_finished, "state_on_finished is undefined")
	assert(state_on_captured, "state_on_captured is undefined")


func _physics_process(delta: float) -> void:
	if not target:
		return
	
	var direction = entity.global_position.direction_to(target.global_position)
	
	vacuum_speed = min(vacuum_speed + vacuum_acceleration * delta, vacuum_top_speed)
	entity.velocity = direction * vacuum_speed
	
	if entity.global_position.distance_to(target.global_position) < finish_distance:
		# Reached close enough to target
		capture()
	elif not vacuum_raycast or not vacuum_raycast.enabled:
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
	
	if hitbox:
		hitbox.enabled = false


func _on_exit_state() -> void:
	super()
	_clear_vacuum_data()


func capture() -> void:
	var capturer = target
	_clear_vacuum_data()
	state_machine.travel_to(state_on_captured, {"capturer": capturer})


func release() -> void:
	_clear_vacuum_data()
	state_machine.travel_to(state_on_finished)


func on_ray_exited(ray: VacuumRaycast) -> void:
	pass


func _clear_vacuum_data() -> void:
	target = null
	vacuum_raycast = null
	vacuum_speed = 0.0
