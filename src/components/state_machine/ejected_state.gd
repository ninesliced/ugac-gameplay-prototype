class_name EjectedState
extends EntityState

@export var visuals: Node2D

@export_group("Eject Physics")
@export var default_eject_speed: float = 800.0
@export var max_bounces: int = 0
@export var max_time: float = 2.0

@export_group("Hitbox & Damage")
@export var hitbox: Hitbox
@export var life_component: LifeComponent
@export var enable_hitbox_distance: float = 100.0
@export var hitbox_enable_delay: float = 0.2
@export var damage_on_bounce: float = 1.0

@export_group("Visuals & Transitions")
@export var particles: CPUParticles2D
@export var state_on_finished: StringName

const EJECTED_COLLISION_LAYER = 10

var direction: Vector2 = Vector2.ZERO
var bounces: int = 0
var speed: float = 0.0
var _time: float = 0.0
var _hitbox_enable_timer: float = 0.0
var _throw_position: Vector2

var _old_hitbox_state: bool = false
var _old_hitbox_damages_enemies: bool = false
var _old_hitbox_damages_players: bool = false

const spin_speed: float = 20.0
var _visuals_rotation: float 

func _ready() -> void:
	super()
	assert(state_on_finished, "state_on_finished is undefined")


func _on_enter_state(params: Dictionary = {}) -> void:
	super(params)
	assert(params.has("direction") and params["direction"] != null, "No direction param")
	assert(params.has("speed"), "No speed param")
	
	direction = params["direction"].normalized()
	bounces = max_bounces
	if params["speed"] >= 0.0:
		speed = params["speed"]
	else:
		speed = default_eject_speed
	_time = max_time
	_throw_position = entity.global_position
	_hitbox_enable_timer = hitbox_enable_delay
	
	if hitbox:
		_old_hitbox_state = hitbox.enabled
		_old_hitbox_damages_enemies = hitbox.damages_enemies
		_old_hitbox_damages_players = hitbox.damages_players
		
		hitbox.damages_enemies = true
		hitbox.damages_players = true
		hitbox.enabled = false
		
		hitbox.set_collision_mask_value(EJECTED_COLLISION_LAYER, true)
	
	if particles:
		particles.emitting = true
	
	if visuals:
		_visuals_rotation = visuals.rotation


func _physics_process(delta: float) -> void:
	super(delta)
	
	_time -= delta
	if _time <= 0.0:
		_finish()
		return
		
	if hitbox and not hitbox.enabled:
		_hitbox_enable_timer -= delta
		if _hitbox_enable_timer <= 0.0 or _throw_position.distance_to(entity.global_position) > enable_hitbox_distance:
			hitbox.enable()
	
	entity.velocity = direction * speed
	entity.move_and_slide()
	
	var collision: KinematicCollision2D = entity.get_last_slide_collision()
	if collision:
		_bounce(collision.get_normal())
	
	if visuals:
		visuals.rotation += spin_speed * delta


func _on_exit_state() -> void:
	super()
	
	if hitbox:
		hitbox.enabled = _old_hitbox_state
		hitbox.damages_enemies = _old_hitbox_damages_enemies
		hitbox.damages_players = _old_hitbox_damages_players
		
		hitbox.set_collision_layer_value(EJECTED_COLLISION_LAYER, false)
	
	if particles:
		particles.emitting = false
	
	if visuals:
		await get_tree().process_frame
		visuals.rotation = 0.0


func _bounce(normal: Vector2) -> void:
	if life_component:
		life_component.damage(damage_on_bounce)
	
	if bounces <= 0:
		_finish()
	else:
		direction = direction.bounce(normal)
		bounces -= 1


func _finish() -> void:
	state_machine.travel_to(state_on_finished)
