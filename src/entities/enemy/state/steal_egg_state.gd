extends EnemyState

const collect_time: float = 1.0
var collect_timer: float = 0.0

var nest: Nest

@onready var capturer_component: CapturerComponent = $"../../CapturerComponent"

func _on_enter_state(params: Dictionary = {}) -> void:
	nest = params.get("nest", null)
	assert(nest, "No nest defined")
	
	collect_timer = collect_time


func _physics_process(delta: float) -> void:
	collect_timer -= delta
	
	if collect_timer <= 0:
		collect_timer = INF
		
		var egg: Egg = nest.release_egg(null, enemy.global_position)
		capturer_component.capture(egg, false)
		
		state_machine.travel_to("WalkToSpawner")
