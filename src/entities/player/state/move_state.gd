extends PlayerState

@export var walk_particles: CPUParticles2D

@export var idle_velocity_threshold: float = 4.0
@export var acceleration: float = 5000.0
@export var speed: float = 400.0

@export var roll_cooldown: float = 0.2
var _roll_cooldown_timer: float = 0.0

@onready var visuals: PlayerVisuals = %Visuals

var _is_walking: bool = false
var revive_bar: float = 0.0


func _ready() -> void:
	super()


func _on_enter_state(params: Dictionary = {}) -> void:
	super(params)
	var input_direction = player.get_vector("game_left", "game_right", "game_up", "game_down")
	_is_walking = _check_should_walk(input_direction)
	_apply_visual_state()
	
	if params.get("previous_state_name", "") == "Rolling":
		_roll_cooldown_timer = roll_cooldown


func _physics_process(delta: float) -> void:
	super(delta)
	
	var input_direction = player.get_vector("game_left", "game_right", "game_up", "game_down")
	
	if input_direction:
		player.velocity = player.velocity.move_toward(input_direction * speed, acceleration * delta)
		player.walk_direction = input_direction.normalized()
	else:
		player.decelerate(delta)
	
	player.move_and_slide()
	
	_update_animation_state(input_direction)
	
	_roll_cooldown_timer = max(_roll_cooldown_timer - delta, 0.0)
	
	if player.is_action_just_pressed("game_action"):
		if player.has_captured_entity():
			state_machine.travel_to("Aiming")
		else:
			state_machine.travel_to("Inhaling")
	
	if player.is_action_just_pressed("game_dash") and _roll_cooldown_timer <= 0:
		state_machine.travel_to("Rolling")


func _on_exit_state() -> void:
	super()
	walk_particles.emitting = false


func _update_animation_state(input_direction: Vector2) -> void:
	var should_walk = _check_should_walk(input_direction)
	
	if should_walk != _is_walking:
		_is_walking = should_walk
		_apply_visual_state()


func _check_should_walk(input_direction: Vector2) -> bool:
	return input_direction != Vector2.ZERO or player.velocity.length() >= idle_velocity_threshold


func _apply_visual_state() -> void:
	if _is_walking:
		visuals.play("Walk")
		walk_particles.emitting = true
	else:
		visuals.play("Idle")
		walk_particles.emitting = false
