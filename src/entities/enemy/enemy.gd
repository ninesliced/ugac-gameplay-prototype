class_name Enemy
extends Actor

@export var hitbox: Hitbox
var spawn_node: Node2D

@onready var label: Label = $Label
@onready var life_component: LifeComponent = $LifeComponent
@onready var sprite: Sprite2D = $Sprite2D

var targets_players: bool = false

func _ready() -> void:
	super()
	hitbox.enabled = true
	targets_players = randf_range(0.0, 1.0) < 0.5
	if targets_players:
		$Sprite2D.modulate = Color.BLUE
		$LifeComponent.max_life = 1
		$LifeComponent.set_life(1)


func _process(delta: float) -> void:
	$Label.text = state_machine.current_state_name


func _physics_process(delta: float) -> void:
	super(delta)


func _on_life_component_damaged(amount: float) -> void:
	var old = Color(sprite.modulate)
	sprite.modulate = Color(20.0, 20.0, 20.0, 1.0)
	await get_tree().create_timer(0.3, false).timeout
	sprite.modulate = old


func _on_life_component_died() -> void:
	die()


func die() -> void:
	super()


func _on_hurtbox_hitbox_entered(area: Hitbox) -> void:
	if area.damages_enemies:
		if area.owner is Entity:
			knockback_from_entity(area.owner, 1000.0)
		life_component.damage(area.damage)
	
	#elif area.owner and area.owner is Enemy:
		#apply_impulse(global_position.direction_to(area.owner.global_position) * 300.0)
