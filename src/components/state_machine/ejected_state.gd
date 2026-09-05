class_name EjectedState
extends EntityState

@export_category("Eject Physics")
@export var eject_speed: float = 800.0
@export var max_bounces: int = 0
@export var max_time: float = 2.0

@export_category("Hitbox & Damage")
@export var hitbox: Hitbox
@export var enable_hitbox_distance: float = 100.0
@export var hitbox_enable_delay: float = 0.2

@export_category("Visuals & Transitions")
@export var particles: CPUParticles2D
@export var state_on_finished: StringName

var direction: Vector2 = Vector2.ZERO
var bounces: int = 0
var _time: float = 0.0
var _hitbox_enable_timer: float = 0.0
var _throw_position: Vector2

var _old_hitbox_state: bool = false
var _old_hitbox_damages_enemies: bool = false
var _old_hitbox_damages_players: bool = false

func _ready() -> void:
	super()
	assert(state_on_finished, "state_on_finished is undefined")


func _on_enter_state(params: Dictionary = {}) -> void:
	super(params)
	assert(params.has("direction") and params["direction"] != null, "No direction param")
	
	# Initialize physics state
	direction = params["direction"].normalized()
	bounces = max_bounces
	_time = max_time
	_throw_position = entity.global_position
	_hitbox_enable_timer = hitbox_enable_delay
	
	# Backup and setup hitbox
	if hitbox:
		_old_hitbox_state = hitbox.enabled
		_old_hitbox_damages_enemies = hitbox.damages_enemies
		_old_hitbox_damages_players = hitbox.damages_players
		
		hitbox.damages_enemies = true
		hitbox.damages_players = true
		hitbox.enabled = false
	
	if particles:
		particles.emitting = true


func _physics_process(delta: float) -> void:
	super(delta)
	
	_time -= delta
	if _time <= 0.0:
		_finish()
		return
		
	# Handle hitbox enabling (triggers on either time or distance)
	if hitbox and not hitbox.enabled:
		_hitbox_enable_timer -= delta
		if _hitbox_enable_timer <= 0.0 or _throw_position.distance_to(entity.global_position) > enable_hitbox_distance:
			hitbox.enable() # Assuming your Hitbox class has an enable() func, otherwise use hitbox.enabled = true
			
	# Movement
	entity.velocity = direction * eject_speed
	entity.move_and_slide()
	
	# Collision and Bouncing
	var collision: KinematicCollision2D = entity.get_last_slide_collision()
	if collision:
		if bounces <= 0:
			_finish()
		else:
			var normal: Vector2 = collision.get_normal()
			direction = direction.bounce(normal)
			bounces -= 1


func _on_exit_state() -> void:
	super()
	entity.rotation = 0.0
	
	# Restore hitbox state
	if hitbox:
		hitbox.enabled = _old_hitbox_state
		hitbox.damages_enemies = _old_hitbox_damages_enemies
		hitbox.damages_players = _old_hitbox_damages_players
		
	if particles:
		particles.emitting = false


func _finish() -> void:
	state_machine.travel_to(state_on_finished)
