extends CanvasLayer

@onready var wave_index_label: Label = $Control/WaveIndexLabel
@onready var wave_spawner: WaveSpawner = $"../WaveSpawner"

func _on_wave_spawner_wave_started() -> void:
	wave_index_label.show()
	wave_index_label.text = "WAVE %d" % [wave_spawner.current_wave_index + 1]
	await get_tree().create_timer(4.0).timeout
	wave_index_label.hide()
