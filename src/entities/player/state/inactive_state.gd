extends PlayerState

@export var duration = 2.0

var time = 0.0

@onready var hitbox: Hitbox = %Hitbox
@onready var hurtbox: Hurtbox = %Hurtbox
@onready var vacuum_hurtbox: VacuumHurtbox = %VacuumHurtbox
@onready var collision_shape: CollisionShape2D = %CollisionShape2D
@onready var visuals: PlayerVisuals = %Visuals

func _on_enter_state(params: Dictionary = {}):
	hitbox.disable()
	hurtbox.disable()
	vacuum_hurtbox.disable()
	collision_shape.disabled = true
	
	visuals.hide()
	time = duration
	
	%RespawnTimeLabel.show()


func _physics_process(delta: float) -> void:
	time -= delta
	if time <= 0:
		state_machine.travel_to("Fainted")
	
	%RespawnTimeLabel.text = "Respawn in %.1fs" % [time]


func _on_exit_state():
	hitbox.enable()
	hurtbox.enable()
	vacuum_hurtbox.enable()
	collision_shape.disabled = false
	
	visuals.show()
	%RespawnTimeLabel.hide()
