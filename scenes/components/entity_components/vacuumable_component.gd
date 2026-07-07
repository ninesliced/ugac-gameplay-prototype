class_name VacuumableComponent
extends EntityComponent

@export var vacuum_acceleration = 800
@export var vacuum_top_speed = 6000
@export var finish_distance = 16

@export_category("State & Hurtbox")
@export var state_machine: StateMachine
@export var hurtbox: Hurtbox
@export var state_on_vacuum_area_entered: StringName
@export var state_on_vacuum_area_exited: StringName

signal finished()
signal finished_uncaptured()
signal finished_captured(capturer: Entity)

var use_states: bool = false

var target: Node2D = null
var target_area: VacuumArea = null
var vacuum_speed: float = 0.0

func _ready() -> void:
	super()
	
	use_states = (state_machine and hurtbox and state_on_vacuum_area_entered and state_on_vacuum_area_exited)
	
	if use_states:
		hurtbox.hitbox_entered.connect(_on_hurtbox_hitbox_entered)
		hurtbox.hitbox_exited.connect(_on_hurtbox_hitbox_exited)

func _physics_process(delta: float) -> void:
	if not active:
		return
	
	var direction = entity.global_position.direction_to(target.global_position)
	
	vacuum_speed = min(vacuum_speed + vacuum_acceleration * delta, vacuum_top_speed)
	entity.velocity = direction * vacuum_speed
	
	if entity.global_position.distance_to(target.global_position) < finish_distance:
		# Reached closed enough to target
		finished_captured.emit(target)
		deactivate()
	
	elif not target_area or not target_area.enabled:
		# Attract area gets disabled
		finished_uncaptured.emit()
		deactivate()
	
	entity.move_and_slide()

func activate(new_target: Node2D, new_target_area: VacuumArea):
	active = true
	target = new_target
	target_area = new_target_area
	vacuum_speed = 0.0

func deactivate():
	active = false
	target = null
	target_area = null
	vacuum_speed = 0.0
	finished.emit()

func has_target() -> bool:
	return target != null

func _on_hurtbox_hitbox_entered(area: Hitbox):
	if area is VacuumArea:
		state_machine.set_state(state_on_vacuum_area_entered, {
			"vacuum_attract_target": area.entity,
			"vacuum_attract_area": area as VacuumArea,
		})

func _on_hurtbox_hitbox_exited(area: Hitbox):
	if area is VacuumArea:
		state_machine.set_state(state_on_vacuum_area_exited) 
