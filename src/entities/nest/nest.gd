class_name Nest
extends Entity

const EGG = preload("uid://ful76yvdlyh6")

@export var egg_count: int = 0

func _process(delta: float) -> void:
	$Label.text = "Eggs: " + str(egg_count)


func _on_hurtbox_ray_entered(ray: VacuumRaycast, enter_pos: Vector2) -> void:
	release_egg(ray, enter_pos)


func add_egg(egg: Egg):
	egg_count += 1
	egg.queue_free()


func release_egg(ray: VacuumRaycast = null, release_pos: Vector2 = global_position) -> Egg:
	if egg_count <= 0:
		return
	
	egg_count -= 1
	
	var egg: Egg = EGG.instantiate()
	egg.global_position = release_pos
	get_parent().add_child(egg)
	
	if ray and ray.owner is Player:
		egg.state_machine.travel_to("Vacuumed", {
			"vacuum_attract_target": ray.owner as Player,
			"vacuum_attract_raycast": ray
		})
	
	return egg


func _to_string() -> String:
	return "<Nest:eggs=%d>" % [egg_count]
