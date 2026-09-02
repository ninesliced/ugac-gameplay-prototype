extends PlayerState

@export var visuals: PlayerVisuals
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
	visuals.play("Roll")


func _on_exit_state():
	super()
	visuals.sprite_rotation = 0.0
	dust_particles.emitting = false


func _physics_process(delta: float) -> void:
	super(delta)
	
	player.velocity = direction * speed
	player.move_and_slide()
	
	dust_particles.emitting = true
	
	var rot_sign = 1
	if direction.x < 0:
		rot_sign = -1
	visuals.sprite_rotation = lerp(0.0, rot_sign * TAU, 1 - (time / duration))
	
	time = max(0.0, time - delta)
	if time <= 0.0:
		state_machine.set_state("Move")
	
