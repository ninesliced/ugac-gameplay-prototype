extends MultiMeshInstance2D

@export var instance_count: int = 200
@export var field_size: Vector2 = Vector2(1920, 1080)
@export var frame_size: Vector2 = Vector2(120, 120)

@export var weights: Array[float] 

@export var blade_scale: Vector2 = Vector2(0.5, 0.5)

var frame_count: int 
var variant_count: int 

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	@warning_ignore("integer_division")
	frame_count = texture.get_size().x / frame_size.x
	@warning_ignore("integer_division")
	variant_count = texture.get_size().y / frame_size.y
	
	assert(weights.size() == variant_count)
	
	var positions: Array[Vector2i] = []
	for i in instance_count:
		positions.append(Vector2(
			randf_range(0.0, field_size.x),
			randf_range(0.0, field_size.y)
		))
	positions.sort_custom(func(a, b): return a.y < b.y)
	
	(material as ShaderMaterial).set_shader_parameter("variant_count", float(variant_count))
	(material as ShaderMaterial).set_shader_parameter("frame_count", float(frame_count))
	
	multimesh.instance_count = instance_count
	var mesh: QuadMesh = multimesh.mesh
	mesh.size = frame_size
	
	for i in instance_count:
		var pos = positions[i]
		
		var flip = -1 if randf() <= 0.5 else 1
		var instance_transform = Transform2D(0.0, blade_scale * Vector2(flip, 1), 0, pos)
		multimesh.set_instance_transform_2d(i, instance_transform)
		
		var frame = randi_range(0, frame_count-1)
		#var variant = randi_range(0, variant_count-1)
		var variant = rng.rand_weighted(weights)
		multimesh.set_instance_custom_data(i, Color(variant, frame, 0, 0))
