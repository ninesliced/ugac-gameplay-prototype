extends CapturedState

var player: Player

func _ready() -> void:
	super()
	
	player = entity as Player


func _process(delta: float) -> void:
	super(delta)
	
	if player.is_action_just_pressed("game_dash"):
		state_machine.travel_to("Rolling") 
