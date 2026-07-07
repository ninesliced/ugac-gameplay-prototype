class_name EjectableComponent
extends EntityComponent

@export var eject_speed := 400.0
@export var max_bounces: int = 0
@export var max_time: float = 2.0

@export_category("Damage")
@export var hitbox: Hitbox
@export var hitbox_enable_delay: float = 0.1

signal finished()

var direction: Vector2 = Vector2.ZERO
var bounces: int = 0
var hitbox_enabled = false
var hitbox_enable_time: float = 0.0

var _time: float = 0.0

func _ready() -> void:
	super()

func activate(direction_: Vector2):
	active = true
	direction = direction_.normalized()
	bounces = max_bounces
	_time = max_time
	
	if hitbox:
		hitbox_enable_time = hitbox_enable_delay
		hitbox_enabled = hitbox.enabled

func deactivate():
	active = false
	if hitbox:
		hitbox.enabled = hitbox_enabled
	
	finished.emit()

func _physics_process(delta: float) -> void:
	if not active:
		return
	
	_time -= delta
	if _time < 0.0:
		deactivate()
	
	hitbox_enable_time = max(hitbox_enable_time - delta, 0.0)
	if hitbox and hitbox_enable_time <= 0:
		hitbox.enable()
	
	entity.velocity = direction * eject_speed
	entity.move_and_slide()
	
	var collision: KinematicCollision2D = entity.get_last_slide_collision()
	if collision:
		if bounces <= 0:
			deactivate()
		else:
			var normal: Vector2 = collision.get_normal()
			direction = direction.bounce(normal)
			bounces -= 1

func _on_wall_detector_body_entered(body: Node2D):
	pass
