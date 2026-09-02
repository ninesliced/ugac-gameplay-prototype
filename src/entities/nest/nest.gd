class_name Nest
extends Actor

const EGG = preload("uid://ful76yvdlyh6")

@export var egg_count: int = 0

func _process(delta: float) -> void:
	$Label.text = "Eggs: " + str(egg_count)


func _on_hurtbox_hitbox_entered(area: Hitbox) -> void:
	#if area is VacuumArea:
		#release_egg(area)
	if area.get_parent() is Egg:
		add_egg(area.get_parent() as Egg)


func add_egg(egg: Egg):
	egg_count += 1
	egg.queue_free()


func release_egg(area = null):
	if egg_count <= 0:
		return
	
	egg_count -= 1
	
	var egg = EGG.instantiate()
	
	if area and area.get_parent() is Player:
		var player = area.get_parent() as Player
		var vector_to_self = global_position - player.global_position
		var distance_along_line = vector_to_self.dot(player.aim_direction)
		var pos = player.global_position + (player.aim_direction * distance_along_line)
		egg.global_position = pos
	
	get_parent().add_child(egg)


func _to_string() -> String:
	return "<Nest:eggs=%d>" % [egg_count]
