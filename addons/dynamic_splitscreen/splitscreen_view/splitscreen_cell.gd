class_name SplitscreenCell
extends Node

@export var color: Color

var active: bool = true
var index: int

var target: Node2D
var polygon_node: Polygon2D

var normalized_polygon: PackedVector2Array = PackedVector2Array([])
var normalized_polygon_center: Vector2
var polygon_area_ratio: float = 0.0

var scaled_bounding_box: Rect2
var scaled_polygon_center: Vector2 = Vector2.ZERO

var average_normalized_merge_position: Vector2 = Vector2.ZERO

var target_position: Vector2 = Vector2.ZERO
var normalized_target_position: Vector2 = Vector2.ZERO

var is_merged: bool = false
var merged_with: Array[int] = []
var merge_parent: int = -1
var weight: float = 0.0

var viewport: SplitscreenSubViewport
var camera: Camera2D
var camera_target_position: Vector2 = Vector2.ZERO

func _init(_index: int, _color: Color):
	index = _index
	color = _color

func deactivate():
	active = false
	if polygon_node.visible:
		polygon_node.hide()
	
func activate():
	active = true
	if not polygon_node.visible:
		polygon_node.show()

func set_merged_with(cluster) -> void:
	merged_with.clear()
	merged_with.append_array(cluster)

func set_camera_target_position(pos: Vector2) -> void:
	camera_target_position = pos
	if camera is SplitscreenCamera2D:
		camera.target_position = pos
