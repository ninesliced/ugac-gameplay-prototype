class_name EjectedState
extends EntityState

@export var ejectable_component: EjectableComponent
@export var state_on_finished: StringName
@export var particles: CPUParticles2D
@export var hitbox: Hitbox
@export var enable_hitbox_distance: float = 100.0

var _old_hitbox_state = false
var _old_hitbox_damages_enemies = false
var _old_hitbox_damages_players = false

var _throw_position: Vector2

func _ready() -> void:
	super()
	assert(ejectable_component, "ejectable_component is undefined")
	assert(state_on_finished, "state_on_finished is undefined")
	
	ejectable_component.finished.connect(_on_ejectable_component_finished)


func _physics_process(delta: float) -> void:
	super(delta)
	
	#entity.rotate(20.0 * delta)
	
	if _throw_position.distance_to(entity.global_position) > enable_hitbox_distance and hitbox:
		hitbox.enabled = true


func _on_enter_state(params: Dictionary = {}):
	super(params)
	assert(params.has("direction") and params["direction"] != null, "No direction param")
	
	ejectable_component.activate(params["direction"])
	_old_hitbox_damages_enemies = hitbox.damages_enemies
	_old_hitbox_damages_players = hitbox.damages_players
	hitbox.damages_enemies = true
	hitbox.damages_players = true
	
	_old_hitbox_state = hitbox.enabled
	hitbox.enabled = false
	
	_throw_position = entity.global_position
	
	if particles:
		particles.emitting = true


func _on_exit_state():
	super()
	if ejectable_component.active:
		ejectable_component.deactivate()
	
	entity.rotation = 0.0
	
	hitbox.enabled = _old_hitbox_state
	hitbox.damages_enemies = _old_hitbox_damages_enemies
	hitbox.damages_players = _old_hitbox_damages_players
	
	if particles:
		particles.emitting = false

func _on_ejectable_component_finished():
	state_machine.set_state(state_on_finished)
