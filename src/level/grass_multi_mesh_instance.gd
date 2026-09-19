extends MultiMeshInstance2D

@export var instance_count: int = 100
@export var field_size: Vector2 = Vector2(1920, 1080)
@export var frame_size: Vector2 = Vector2(120, 120)

@export var blade_scale: Vector2 = Vector2(0.75, 0.75)

var frame_count: int 
var variant_count: int 

func _ready() -> void:
	frame_count = texture.get_size().x / frame_size.x
	variant_count = texture.get_size().y / frame_size.y
	
	(material as ShaderMaterial).set_shader_parameter("variant_count", float(variant_count))
	(material as ShaderMaterial).set_shader_parameter("frame_count", float(frame_count))
	
	multimesh.instance_count = instance_count
	var mesh: QuadMesh = multimesh.mesh
	mesh.size = frame_size
	
	for i in instance_count:
		var pos = Vector2(
			randf_range(0.0, field_size.x),
			randf_range(0.0, field_size.y)
		)
		
		var instance_transform = Transform2D(0.0, blade_scale, 0, pos)
		multimesh.set_instance_transform_2d(i, instance_transform)
		
		var frame = randi_range(0, frame_count-1)
		var variant = randi_range(0, variant_count-1)
		multimesh.set_instance_custom_data(i, Color(variant, frame, 0, 0))
