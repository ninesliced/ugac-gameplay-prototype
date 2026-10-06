class_name Math
extends Node

static func get_weighted_random(weights: Dictionary) -> Variant:
	var total_weight: float = 0.0
	for w in weights.values():
		total_weight += w
	
	var roll: float = randf_range(0.0, total_weight)
	
	for item in weights:
		roll -= weights[item]
		if roll <= 0.0:
			return item
	
	# fallback if floating point errors
	return weights.keys().back()


static func get_random_point_radial(radius: float):
	var angle = randf() * TAU
	var distance = sqrt(randf()) * radius
	return Vector2.from_angle(angle) * distance
