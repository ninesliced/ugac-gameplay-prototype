class_name EntityState
extends State

var entity: Entity

func _ready() -> void:
	super()
	entity = state_machine.entity
	assert(entity != null, "Entity is not defined in State Machine")

func _physics_process(delta: float) -> void:
	entity.velocity = entity.velocity.move_toward(Vector2.ZERO, entity.deceleration*delta)

func _process(delta: float) -> void:
	pass
