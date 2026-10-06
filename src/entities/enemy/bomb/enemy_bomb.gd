extends Enemy

const EXPLOSION = preload("uid://d24l05xjweni5")

func _on_life_component_died() -> void:
	var explosion = EXPLOSION.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position 
	queue_free()
	
	super()
