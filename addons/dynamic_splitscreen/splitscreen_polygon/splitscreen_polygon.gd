@icon("./SplitscreenPolygon.svg")
class_name SplitscreenPolygon
extends Polygon2D

@export var outline_color: Color = Color.WHITE
@export var outline_width: float = 3.0

var segment_widths: Array[float] = [2.0, 10.0, 5.0] 

func _process(delta: float) -> void:
	var mat = material as ShaderMaterial
	$Line2D.points = polygon
	$Line2D.width = outline_width
	$Line2D.default_color = outline_color
	#mat.set_shader_parameter("points", polygon)
	#mat.set_shader_parameter("widths", segment_widths)
	#mat.set_shader_parameter("point_count", polygon.size())
