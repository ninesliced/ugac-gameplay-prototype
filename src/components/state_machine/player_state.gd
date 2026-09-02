class_name PlayerState
extends ActorState

var player: Player

func _ready() -> void:
	super()
	player = state_machine.entity as Player

func _physics_process(delta: float) -> void:
	super(delta)
