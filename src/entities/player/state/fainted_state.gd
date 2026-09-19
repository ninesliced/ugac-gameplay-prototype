extends PlayerState

@export var acceleration: float = 500.0
@export var deceleration: float = 200.0
@export var speed: float = 400.0

@onready var hitbox: Hitbox = %Hitbox
@onready var hurtbox: Hurtbox = %Hurtbox
@onready var vacuum_hurtbox: VacuumHurtbox = %VacuumHurtbox
@onready var collision_shape: CollisionShape2D = %CollisionShape2D
@onready var life_component: RegeneratingLifeComponent = %LifeComponent

@onready var visuals: PlayerVisuals = %Visuals
@onready var bubble_sprite: Sprite2D = %BubbleSprite

const EJECTED_COLLISION_LAYER: int = 10
var _old_collision_layer: int = 0

func _on_enter_state(params: Dictionary = {}):
	super(params)
	visuals.play("Idle")
	
	hurtbox.enable()
	vacuum_hurtbox.enable()
	
	_old_collision_layer = hurtbox.collision_layer
	hurtbox.collision_layer = 0
	hurtbox.set_collision_layer_value(EJECTED_COLLISION_LAYER, true)
	
	bubble_sprite.show()
	life_component.damaged.connect(_on_life_component_damaged)
	life_component.heal(2)
	
	player.velocity = Vector2.ZERO
	
	player.is_targetable = false


func _process(delta: float) -> void:
	var s = sign(player.velocity.x)
	if s == 0: s = 1
	
	visuals.sprite_rotation += s * player.velocity.length() * delta * 0.05
	visuals.flip_h = (player.velocity.x < 0)


func _physics_process(delta: float) -> void:
	var input_direction = player.get_vector("game_left", "game_right", "game_up", "game_down")
	
	if input_direction:
		player.velocity = player.velocity.move_toward(input_direction * speed, acceleration * delta)
		player.walk_direction = input_direction.normalized()
	else:
		entity.velocity = entity.velocity.move_toward(Vector2.ZERO, deceleration*delta)
	
	player.move_and_slide()


func _on_exit_state():
	super()
	
	visuals.sprite_rotation = 0.0
	
	bubble_sprite.hide()
	life_component.damaged.disconnect(_on_life_component_damaged)
	
	hurtbox.collision_layer = _old_collision_layer
	
	player.is_targetable = true


func _finish():
	player.revive()


func _on_life_component_damaged(amount: float, damager: Entity):
	_finish()
