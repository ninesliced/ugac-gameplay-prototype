extends PlayerState

@export var visuals: PlayerVisuals
@export var walk_particles: CPUParticles2D

@export var idle_velocity_threshold: float = 4.0
@export var acceleration: float = 3500.0
@export var speed: float = 400.0

var _is_walking: bool = false

func _ready() -> void:
	super()

func _physics_process(delta: float) -> void:
	super(delta)
	
	var input_direction = player.get_vector("game_left", "game_right", "game_up", "game_down")
	
	if input_direction:
		player.velocity = player.velocity.move_toward(input_direction * speed, acceleration * delta)
		player.walk_direction = input_direction.normalized()
		
	player.move_and_slide()
	
	_update_animation_state(input_direction)
	
	if player.is_action_just_pressed("game_action"):
		if player.has_captured_entity():
			player.exhale()
		else:
			state_machine.set_state("Inhaling")
			
	if player.is_action_just_pressed("game_dash"):
		state_machine.set_state("Rolling")

func _on_enter_state(params: Dictionary = {}) -> void:
	super(params)
	var input_direction = player.get_vector("game_left", "game_right", "game_up", "game_down")
	_is_walking = _check_should_walk(input_direction)
	_apply_visual_state()

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
