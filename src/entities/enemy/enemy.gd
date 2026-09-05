class_name Enemy
extends Actor

@export var hitbox: Hitbox
var spawn_node: Node2D

@onready var label: Label = $Label
@onready var life_component: LifeComponent = $LifeComponent

func _ready() -> void:
	super()
	hitbox.enabled = true


func _process(delta: float) -> void:
	$Label.text = state_machine.current_state_name


func _physics_process(delta: float) -> void:
	pass


func _on_life_component_died() -> void:
	queue_free()


func _on_hurtbox_hitbox_entered(area: Hitbox) -> void:
	if area.damages_enemies:
		if area.owner is Entity:
			knockback_from_entity(area.owner, 1000.0)
		life_component.damage(area.damage)
	
	#elif area.owner and area.owner is Enemy:
		#apply_impulse(global_position.direction_to(area.owner.global_position) * 300.0)
