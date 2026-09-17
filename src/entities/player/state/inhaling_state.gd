extends PlayerState


@export var vacuum: Node2D
@export var vacuum_particles: CPUParticles2D
@export var vacuum_dust_particles: CPUParticles2D
@export var vacuum_raycast: VacuumRaycast

@onready var visuals: PlayerVisuals = %Visuals
@onready var capturer_component: CapturerComponent = $"../../CapturerComponent"


func _ready() -> void:
	super()


func _on_enter_state(params: Dictionary = {}):
	super(params)
	vacuum_raycast.enable()
	
	capturer_component.captured.connect(_capturer_component_captured)
	
	visuals.play("Inhale")


func _physics_process(delta: float) -> void:
	player.decelerate(delta)
	
	player.walk_direction = player.aim_direction
	vacuum_raycast.angle = player.aim_angle
	vacuum_raycast.length = player.vacuum_range
	vacuum.rotation = player.aim_angle
	
	vacuum_particles.emitting = true
	vacuum_dust_particles.emitting = true
	
	visuals.flip_h = player.aim_direction.x < 0
	
	if player.is_action_just_released("game_action"):
		state_machine.travel_to("Move")
	
	if player.is_action_just_pressed("game_dash"):
		state_machine.travel_to("Rolling")
	
	player.move_and_slide()


func _on_exit_state():
	vacuum_particles.emitting = false
	vacuum_dust_particles.emitting = false
	
	capturer_component.captured.disconnect(_capturer_component_captured)
	
	vacuum_raycast.disable()


func _capturer_component_captured(new_captured_entity: Entity) -> void:
	state_machine.travel_to("Move")
