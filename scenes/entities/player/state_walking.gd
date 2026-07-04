extends PlayerState

@export var visuals: StackedAnimatedSprite
@export var walk_particles: CPUParticles2D

@export var idle_velocity_threshold = 4.0
@export var acceleration = 2500.0
@export var speed = 300.0

func _ready() -> void:
	super()

func _physics_process(delta: float) -> void:
	super(delta)
	
	var input_direction = player.get_vector("game_left", "game_right", "game_up", "game_down")
	if input_direction:
		player.velocity = player.velocity.move_toward(input_direction*speed, acceleration*delta)
		player.walk_direction = input_direction.normalized()
	player.move_and_slide()
	
	# I'm doing two if's to specifically exclude the case where walk_direction.x = 0.
	if player.walk_direction.x < 0:
		visuals.flip_h = true
	if player.walk_direction.x > 0:
		visuals.flip_h = false
	
	walk_particles.emitting = true
	
	if not input_direction and player.velocity.length() < idle_velocity_threshold:
		state_machine.set_state("Idle")
	
	if player.is_action_just_pressed("game_action"):
		if player.has_captured_entity():
			player.exhale()
		else:
			state_machine.set_state("Inhaling")
	
	if player.is_action_just_pressed("game_dash"):
		state_machine.set_state("Rolling")

func _on_enter_state(params: Dictionary = {}):
	super(params)
	visuals.play("walk")

func _on_exit_state():
	super()
	walk_particles.emitting = false
