class_name EnemyEggStealer
extends Enemy

@export var hitbox: Hitbox

var spawn_node: Node2D
var targets_players: bool = false

@onready var sprite: Sprite2D = %Sprite2D

func _ready() -> void:
	super()
	hitbox.enabled = true
	targets_players = randf_range(0.0, 1.0) < 0.5
	if targets_players:
		sprite.modulate = Color.BLUE
		life_component.max_life = 1
		life_component.set_life(1)


func _process(delta: float) -> void:
	pass
	#$Label.text = state_machine.current_state_name


func _physics_process(delta: float) -> void:
	super(delta)


func die() -> void:
	super()


func _on_hurtbox_hitbox_entered(area: Hitbox) -> void:
	super(area)
	
	#elif area.owner and area.owner is Enemy:
		#apply_impulse(global_position.direction_to(area.owner.global_position) * 300.0)
