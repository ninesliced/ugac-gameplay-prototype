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
	if life_component:
		label.text = "%s/%s" % [int(life_component.life), int(life_component.max_life)]


func _on_hurtbox_recieved_damage(area: Hitbox) -> void:
	print("RECIEVED ", area)


func _physics_process(delta: float) -> void:
	pass


func _on_life_component_died() -> void:
	queue_free()
