class_name EnemyEggStealer
extends Enemy

@export var hitbox: Hitbox

@onready var sprite: Sprite2D = %Sprite2D

func _ready() -> void:
	super()
	hitbox.enabled = true


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	super(delta)


func die() -> void:
	super()


func _on_hurtbox_hitbox_entered(area: Hitbox) -> void:
	super(area)
