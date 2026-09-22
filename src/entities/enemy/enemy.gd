class_name Enemy
extends Actor

@onready var visuals: Node2D = $Visuals
@onready var life_component: LifeComponent = $LifeComponent
@onready var hurtbox: Hurtbox = $Hurtbox

func _ready() -> void:
	super()
	
	life_component.damaged.connect(_on_life_component_damaged)
	life_component.died.connect(_on_life_component_died)
	hurtbox.hitbox_entered.connect(_on_hurtbox_hitbox_entered)


func _on_life_component_died() -> void:
	die()


func _on_life_component_damaged(amount: float) -> void:
	var old = visuals.modulate
	visuals.modulate = Color(20.0, 20.0, 20.0, 1.0)
	await get_tree().create_timer(0.3, false).timeout
	visuals.modulate = old


func _on_hurtbox_hitbox_entered(area: Hitbox) -> void:
	if area.damages_enemies:
		if area.owner is Entity:
			knockback_from_entity(area.owner, 1000.0)
		life_component.damage(area.damage)
