class_name ActorState
extends EntityState

var actor: Actor

func _ready() -> void:
	super()
	actor = entity as Actor


func _physics_process(delta: float) -> void:
	super(delta)
