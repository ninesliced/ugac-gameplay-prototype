extends PlayerState

@onready var visuals: PlayerVisuals = %Visuals
@onready var save_me_label: Label = %SaveMeLabel


@export var acceleration: float = 3500.0
@export var speed: float = 100.0

func _on_enter_state(params: Dictionary = {}):
	super(params)
	visuals.play("Damaged")
	save_me_label.show()
	save_me_label.text = "Save me!"
	
	$"../../Hitbox/CollisionShape2D".disabled = true
	$"../../Hurtbox/CollisionShape2D".disabled = true
	$"../../VacuumHurtbox/CollisionShape2D".disabled = true
	$"../../VacuumHurtbox".disable()

func _physics_process(delta: float) -> void:
	super(delta)
	var input_direction = player.get_vector("game_left", "game_right", "game_up", "game_down")
	
	if input_direction:
		player.velocity = player.velocity.move_toward(input_direction * speed, acceleration * delta)
		player.walk_direction = input_direction.normalized()
		
	player.move_and_slide()
	


func _on_exit_state():
	super()
	save_me_label.hide()
	
	$"../../Hitbox/CollisionShape2D".disabled = false
	$"../../Hurtbox/CollisionShape2D".disabled = false
	$"../../VacuumHurtbox/CollisionShape2D".disabled = false
	$"../../VacuumHurtbox".active = true
