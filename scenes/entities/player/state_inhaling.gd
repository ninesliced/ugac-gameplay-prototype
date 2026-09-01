extends PlayerState

@export var visuals: PlayerVisuals

@export var vacuum: Node2D
@export var vacuum_particles: CPUParticles2D
@export var vacuum_dust_particles: CPUParticles2D
@export var vacuum_raycast: VacuumRaycast

func _ready() -> void:
	super()

func _on_enter_state(params: Dictionary = {}):
	super(params)
	vacuum_raycast.enabled = true
	
	# Animation
	visuals.play("Inhale")

func _on_exit_state():
	super()
	vacuum_particles.emitting = false
	vacuum_dust_particles.emitting = false
	
	vacuum_raycast.enabled = false

func _physics_process(delta: float) -> void:
	super(delta)
	
	player.walk_direction = player.aim_direction
	vacuum_raycast.direction = player.aim_angle
	vacuum_raycast.length = player.vacuum_range
	vacuum.rotation = player.aim_angle
	
	vacuum_particles.emitting = true
	vacuum_dust_particles.emitting = true
	
	visuals.flip_h = player.aim_direction.x < 0
	
	if player.is_action_just_released("game_action"):
		state_machine.set_state("Move")
	
	if player.is_action_just_pressed("game_dash"):
		state_machine.set_state("Rolling")
	
	player.move_and_slide()
