extends PlayerState

@export var visuals: StackedAnimatedSprite
@export var dust_particles: CPUParticles2D

@export var speed = 300.0
@export var duration = 0.3

var time = 0.0
var direction := Vector2.RIGHT

func _ready() -> void:
	super()

func _on_enter_state(params: Dictionary = {}):
	super(params)
	time = duration
	direction = player.aim_direction

func _on_exit_state():
	super()
	visuals.rotation = 0.0
	dust_particles.emitting = false

func _physics_process(delta: float) -> void:
	super(delta)
	
	player.velocity = direction * speed
	player.move_and_slide()
	
	dust_particles.emitting = true
	
	var sign = 1
	if direction.x < 0:
		sign = -1
	visuals.rotation += sign * delta * (TAU /duration)
	
	time = max(0.0, time - delta)
	if time <= 0.0:
		state_machine.set_state("Walking")
	
