extends CanvasLayer

@onready var wave_index_label: Label = $Control/WaveIndexLabel
@onready var wave_spawner: WaveSpawner = $"../WaveSpawner"
@onready var wave_indicator_hud: Control = $WaveIndicatorHUD

@onready var arena: Arena2D = $"../Arena"

func _ready() -> void:
	wave_indicator_hud.wave_count = arena.get_wave_count()
	arena.wave_started.connect(_on_wave_spawner_wave_started)


func _process(delta: float) -> void:
	var enemy_count = get_tree().get_nodes_in_group("enemy").size()
	
	$"../UI/Control/EnemiesLeft".text = "Enemies left: %d" % [enemy_count]


func _on_wave_spawner_wave_started() -> void:
	wave_indicator_hud.open()
	await get_tree().create_timer(1.0).timeout
	wave_indicator_hud.focus_on(arena.get_current_wave_index())
	await get_tree().create_timer(4.0).timeout
	wave_indicator_hud.close()
	
	
	#wave_index_label.show()
	#wave_index_label.text = "WAVE %d" % [wave_spawner.current_wave_index + 1]
	#wave_index_label.hide()
