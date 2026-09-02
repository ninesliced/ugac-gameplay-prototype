@tool
class_name Star2D
extends Polygon2D

@export var peaks: int = 10
@export var peak_randomness: int = 2
@export_range(0.0, 1.0, 0.001) var angle_randomness: float = 0.0
@export_range(0, 360, 0.01, "radians_as_degrees") var min_start_angle: float = 0.0
@export_range(0, 360, 0.01, "radians_as_degrees") var max_start_angle: float = TAU
@export var low_radius: float = 20.0
@export var high_radius: float = 40.0
@export var low_radius_randomness: float = 2.0
@export var high_radius_randomness: float = 2.0
@export var star_scale: float = 1
@export var scale_profile: Curve

## The seed to use for the Random Number Generator. Set to -1 if seedless.
@export var seed: int = -1

@export_tool_button("Generate Star", "Reload") var _generate = generate

var rng = RandomNumberGenerator.new()

func generate():
	var points = PackedVector2Array()
	
	rng = RandomNumberGenerator.new()
	if seed == -1:
		rng.randomize()
	else:
		rng.set_seed(seed)
	
	var nb_peaks = peaks + rng.randi_range(-peak_randomness, peak_randomness)
	
	var a_offset = rng.randf_range(min_start_angle, max_start_angle)
	var a_step = TAU / (float(nb_peaks) * 2.0)
	var low = false
	for i in range(nb_peaks * 2):
		var a = a_offset + (a_step) * i + rng.randf_range(-0.5, 0.5) * angle_randomness
		a = fmod(a, TAU)
		
		var r: float
		if low:
			r = low_radius + rng.randf_range(-low_radius_randomness, low_radius_randomness)
		else:
			r = high_radius + rng.randf_range(-high_radius_randomness, high_radius_randomness)
		
		var s = star_scale
		if scale_profile:
			s = s * scale_profile.sample(a / TAU)
		
		var final_radius = r * s
		var p = offset + Vector2.RIGHT.rotated(-a) * final_radius
		
		points.append(p)
		low = not low
	
	polygon = points
