class_name EntityState
extends State

var entity: Entity

func _ready() -> void:
	super()
	assert(owner is Entity, "Entity is not defined in State Machine")
	entity = owner


func _physics_process(delta: float) -> void:
	pass


func _process(delta: float) -> void:
	pass
