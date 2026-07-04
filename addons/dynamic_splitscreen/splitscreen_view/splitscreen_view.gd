@icon("uid://da4nmdema6u63")
class_name SplitscreenView
extends Control

## A view that displays multiple camera views at a time. Useful for multiplayer 
## splitscreen multiplayer games.

# Author: Léo Bernard (@Yolwoocle)
# AI disclosure: No code that is the result of Generative AI is present in 
# the source code of this add-on.


## The nodes that the ScreenSplitter will try to follow. 
@export var initial_targets: Array[Node2D]

@export_group("Visuals")
## The palette used to color the splitscreen views.
@export var palette = [
	Color("F34A50"),
	Color("4CBD76"),
	Color("F3D852"),
	Color("4975DB"),
	Color("B149DB"),
	Color("FC933D"),
	Color("65E0E6"),
	Color("A2A5AA")
]

## The color of the outline when displaying a merged cell.
@export var merged_outline_color = Color.WHITE

## The thickness of the outlines of the cells.
@export var outline_thickness = 4.0

## The speed at which the cells' outlines is interpolated.
@export var outline_thickness_interpolation_speed = 8.0

## Default zoom value for cameras.
@export var default_camera_zoom: float = 1.0

## Whether the viewports should snap transforms to the nearest pixel.
@export var snap_2d_transforms_to_pixel: bool = false


@export_group("Weight adjustement", "weight_adjustment_")
## By default, all cells attempt to balance each other out so that every cell 
## has about the same area. This controls whether this is enabled or not.
@export var weight_adjustment_enabled = true

## How quickly a cell tries to converge towards equilibrium. 
@export var weight_adjustment_rate = 1.0

## How many iterations of the convergence algorithm to run on every frame.
@export var weight_adjustment_iterations = 10

## How close two points have to be in order for the weight adjustment algorithm 
## to be disabled on two cells, to avoid camera issues. (in normalized space, 
## which means that positions are normalized to the [0.0, 1.0] range, based on 
## a rectangle that fits all the targets, plus some 
## [member bounding_rect_padding]). 
@export_range(0.0, 1.0, 0.001) var weight_adjustment_deadzone = 0.06


@export_group("Cell merging")
## The distance in pixels at which two cells are merged. 
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var merge_distance: float = 200.0

## How much padding the algorithm adds to the bounding box that fits all the
## targets. Please note that this does not correspond to a visual padding but is
## only used in the algorithm internally. Lower values may lead to more sudden
## cell movement at close distances.
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var bounding_rect_padding: float = 200.0

## Array mapping indexes to the [SplitscreenCell]s of this SplitscreenView.
var cells: Array[SplitscreenCell] = []

var _polygon_scene: PackedScene = preload("../splitscreen_polygon/splitscreen_polygon.tscn")
var _splitscreen_sub_viewport_scene: PackedScene = preload("../splitscreen_sub_viewport/splitscreen_sub_viewport.tscn")

const merged_outline_width = 0.0

func _ready() -> void:
	# Pad out the palette with random colors if necessary
	for i in cells.size():
		if i >= palette.size():
			palette.append(Color(randf(), randf(), randf(), 1.0))
	
	for i in cells.size():
		add_cell(initial_targets[i])
	
	var polygons = Node2D.new()
	polygons.name = "Polygons"
	add_child(polygons)
	
	_generate_polygons()


func _process(delta: float) -> void:
	_adjust_weights(delta)
	_apply_polygon_visuals(delta)
	_update_cameras(delta)

################################################################################

#region --- Public methods

func add_cell(target: Node2D = null) -> void:
	var index = cells.size()
	var cell = SplitscreenCell.new(index, palette[index])
	cell.target = target
	cells.append(cell)
	
	_create_viewport(index)
	_init_polygon(index)


func remove_cell(index: int) -> void:
	assert(0 <= index and index < cells.size(), "Cell doesn't exist")
	cells.pop_at(index)


func remove_cell_with_target(target: Node2D) -> void:
	for i in cells.size():
		if cells[i].target == target:
			remove_cell(i)
	assert(false, "Given target doesn't exist")


func set_target(index: int, target: Node2D) -> void:
	assert(0 <= index and index < cells.size(), "Index out of range")
	cells[index].target = target


func get_target(index: int) -> Node2D:
	assert(0 <= index and index < cells.size(), "Index out of range")
	return cells[index].target


func get_cell(index: int) -> SplitscreenCell:
	assert(0 <= index and index < cells.size(), "Index out of range")
	return cells[index]


func get_cell_count() -> int:
	return cells.size()

#endregion

################################################################################

#region --- Polygons

# Returns the center of mass of a polygon
func _get_polygon_center_of_mass(_polygon: PackedVector2Array) -> Vector2:
	var area = 0.0
	var centroid = Vector2()
	
	var n = _polygon.size()
	if n < 3:
		return Vector2()  # Not a polygon
	
	for i in range(n):
		var current = _polygon[i]
		var next = _polygon[(i + 1) % n]
		var cross = current.x * next.y - next.x * current.y
		area += cross
		centroid += (current + next) * cross
	
	area *= 0.5
	if abs(area) < 0.00001:
		return Vector2()  # Degenerate polygon
	
	centroid /= (6.0 * area)
	return centroid


# Returns the area of a triangle
func _triangle_area(a: Vector2, b: Vector2, c: Vector2) -> float:
	return abs((a.x * (b.y - c.y) +
		b.x * (c.y - a.y) +
		c.x * (a.y - b.y)) / 2.0)


# Returns the area of a polygon
func _polygon_area(polygon: PackedVector2Array) -> float:
	var triangles = Geometry2D.triangulate_polygon(polygon)
	if triangles.is_empty():
		return 0.0
	
	var area = 0.0
	for i in range(0, triangles.size(), 3):
		area += _triangle_area(polygon[triangles[i]], polygon[triangles[i+1]], polygon[triangles[i+2]])
	
	return area


func _scale_polygon_to_size(polygon: PackedVector2Array) -> PackedVector2Array:
	var scaled := PackedVector2Array()
	for p in polygon:
		scaled.append(p * size)
	return scaled


# Returns the bounding box of a polygon
func _get_polygon_bounding_box(polygon: PackedVector2Array) -> Rect2:
	if polygon.is_empty():
		return Rect2()
	
	var min_x: float = polygon[0].x
	var max_x: float = polygon[0].x
	var min_y: float = polygon[0].y
	var max_y: float = polygon[0].y
	
	for i in range(1, polygon.size()):
		var point: Vector2 = polygon[i]
		
		min_x = min(min_x, point.x)
		max_x = max(max_x, point.x)
		min_y = min(min_y, point.y)
		max_y = max(max_y, point.y)
	
	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))


func _compute_average_merge_positions() -> void:
	for i in cells.size():
		var avg_center = Vector2.ZERO 
		var total_area = 0.0
		
		for j in cells[i].merged_with:
			var center = cells[j].normalized_polygon_center
			var area = cells[j].polygon_area_ratio
			avg_center += area * center
			total_area += area
		
		var merge_pos = avg_center / total_area
		
		for j in cells[i].merged_with:
			cells[j].average_normalized_merge_position = merge_pos


# Initialize and create polygon
func _init_polygon(index: int):
	var poly_node: SplitscreenPolygon = _polygon_scene.instantiate()
	$Polygons.add_child(poly_node)
	
	cells[index].polygon_node = poly_node
	poly_node.outline_width = outline_thickness 
	poly_node.outline_color = cells[index].color

#endregion

################################################################################

# Computes a Dictionary that maps pairs of point indices to their 
# respective distance between targets
func _compute_distance_matrix() -> Dictionary[Vector2i, float]:
	var distances: Dictionary[Vector2i, float] = {}
	
	for i in cells.size():
		for j in range(i+1, cells.size()):
			var pos_i = cells[i].target.global_position
			var pos_j = cells[j].target.global_position
			var dist = pos_i.distance_to(pos_j)
			distances[Vector2i(i, j)] = dist
			distances[Vector2i(j, i)] = dist
	
	return distances


# Computes the on-screen distance between the center of two cells.
func _compute_on_screen_distance(cell_i: int, cell_j: int):
	var center_i = cells[cell_i].scaled_polygon_center
	var center_j = cells[cell_j].scaled_polygon_center
	return center_i.distance_to(center_j)


# Finds the cell with the closest target in a cluster from a given cell.
func _find_closest_point_in_cluster(cell_i: int, cluster: Array, distance_matrix: Dictionary[Vector2i, float]) -> int:
	if cluster.size() == 1:
		return cluster[0]
	
	var min_dist: float = INF
	var min_point: int = -1
	for cell_j in cluster:
		if cell_i == cell_j:
			continue
		
		var dist = distance_matrix[Vector2i(cell_i, cell_j)]
		if dist < min_dist:
			min_dist = dist
			min_point = cell_j
	
	return min_point


# Clusters cell targets by distance, merging them if close enough.
func _find_clusters():
	var clusters = {} # Type: Dictionary[int, Array[int]]
	for i in cells.size():
		clusters[i] = [i]
	
	var distances = _compute_distance_matrix()
	var max_iterations = cells.size()
	
	for it in max_iterations:
		for node_i in cells.size():
			for cluster_j in cells.size():
				if node_i == cluster_j:
					continue
				if clusters[cluster_j].is_empty():
					continue
				
				var closest_point = _find_closest_point_in_cluster(node_i, clusters[cluster_j], distances)
				if closest_point == -1:
					continue
				
				var on_screen_distance = cells[node_i].scaled_polygon_center.distance_to(cells[closest_point].scaled_polygon_center)
				if distances[Vector2i(node_i, closest_point)] <= merge_distance:
					clusters[node_i].append_array(clusters[cluster_j])
					clusters[cluster_j].clear()
	
	return clusters


# Get the average position of the targets in a cluster
func _get_cluster_target_average_position(cluster: Array[int]) -> Vector2:
	var avg = Vector2.ZERO
	for i in cluster:
		avg += cells[i].target.global_position
	avg /= cluster.size()
	return avg


func _compute_cell_targets():
	for i in cells.size():
		cells[i].target_position = cells[i].target.global_position
	
	_compute_normalized_cell_targets()


## Computes normalized_target_position, which is a position in the (0-1, 0-1) 
## range used for the polygon slicing algorithm
func _compute_normalized_cell_targets():
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF
	
	for i in cells.size():
		min_x = min(min_x, cells[i].target_position.x - bounding_rect_padding)
		max_x = max(max_x, cells[i].target_position.x + bounding_rect_padding)
		min_y = min(min_y, cells[i].target_position.y - bounding_rect_padding)
		max_y = max(max_y, cells[i].target_position.y + bounding_rect_padding)
	
	for i in cells.size():
		cells[i].normalized_target_position.x = remap(cells[i].target_position.x, min_x, max_x, 0.0, 1.0)
		cells[i].normalized_target_position.y = remap(cells[i].target_position.y, min_y, max_y, 0.0, 1.0)


## Cuts a polygon accord to its (weighted) bisector and only keeps the part closest to p_i
func _clip_by_bisector(polygon: PackedVector2Array, p_i: Vector2, p_j: Vector2, w_i: float, w_j: float) -> PackedVector2Array:
	if polygon.size() < 3:
		return polygon
	
	var dist_sq := p_i.distance_squared_to(p_j)
	if dist_sq == 0.0:
		return polygon
	
	# Shift the dividing line away from the point with the larger weight
	var mid_point := (p_i + p_j) / 2.0
	if w_i != w_j:
		var shift_amount: float = (w_i - w_j) / (2.0 * dist_sq)
		mid_point += (p_j - p_i) * shift_amount
	
	var dir_to_j := (p_j - p_i).normalized()
	var bisector_dir := Vector2(-dir_to_j.y, dir_to_j.x)
	
	# Create an enormous cutter polygon
	# Find the farthest away point to make sure that the cutter polygon is large enough
	var max_dist := 0.0
	for p in polygon:
		max_dist = max(max_dist, p.distance_to(mid_point))
	max_dist += 10.0
	
	var p1 := mid_point - (bisector_dir * max_dist)
	var p2 := mid_point + (bisector_dir * max_dist)
	var p3 := p2 + (dir_to_j * max_dist)
	var p4 := p1 + (dir_to_j * max_dist)
	
	var cutter := PackedVector2Array([p1, p2, p3, p4])
	
	var clipped := Geometry2D.clip_polygons(polygon, cutter)
	
	if clipped.is_empty():
		return PackedVector2Array()
	
	return clipped[0]


func _get_normalized_rect_polygon() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(1.0, 0.0),
		Vector2(1.0, 1.0),
		Vector2(0.0, 1.0),
	])


func _generate_polygons():
	# We start with a rectangle
	var base_poly := _get_normalized_rect_polygon()
	var final_polygons_size = 0
	
	# Merge closeby cells
	var clusters = _find_clusters()
	
	for i in cells.size():
		var cluster = clusters[i]
		cells[i].set_merged_with(cluster)
		for j in cluster:
			cells[j].is_merged = (cells[i].merged_with.size() != 1)
			cells[j].merge_parent = i
	
	_compute_average_merge_positions()
	_compute_cell_targets()
	
	# Generate the specific cell for each target
	for i in cells.size():
		var p_i = cells[i].normalized_target_position
		var current_cell = base_poly
		
		for j in cells.size():
			if i == j:
				continue
			if not cells[j].active:
				continue
			
			var p_j = cells[j].normalized_target_position
			current_cell = _clip_by_bisector(current_cell, p_i, p_j, cells[i].weight, cells[j].weight)
			
			# The cell was entirely clipped away
			if current_cell.size() < 3:
				break
		
		final_polygons_size += 1
		
		cells[i].normalized_polygon = current_cell
		cells[i].normalized_polygon_center = _get_polygon_center_of_mass(current_cell)
		cells[i].polygon_area_ratio = _polygon_area(current_cell)


func _apply_polygon_visuals(delta: float):
	for i in cells.size():
		var polygon = cells[i].normalized_polygon
		var scaled_polygon = _scale_polygon_to_size(polygon)
		
		var poly_node: SplitscreenPolygon = cells[i].polygon_node
		var sub_viewport: SubViewport = cells[i].viewport
		poly_node.polygon = scaled_polygon
		poly_node.texture = sub_viewport.get_texture()
		
		var merge_parent = cells[cells[i].merge_parent]
		var target_thickness = outline_thickness
		if (merge_parent.merged_with.size() == cells.size()):
			target_thickness = 0.0 
		poly_node.outline_width = move_toward(poly_node.outline_width, target_thickness, delta * outline_thickness_interpolation_speed)
		
		if merge_parent.merged_with.size() == 1:
			poly_node.outline_color = cells[i].color
		else:
			poly_node.outline_color = Color.TRANSPARENT# merged_outline_color
		
		var center_of_mass = _get_polygon_center_of_mass(scaled_polygon)
		cells[i].scaled_polygon_center = center_of_mass
		
		cells[i].scaled_bounding_box = _get_polygon_bounding_box(scaled_polygon)


func _get_closest_neighbor_distance(cell_i: int) -> float:
	var min_dist = INF
	var pos_i = cells[cell_i].normalized_target_position
	
	for j in cells.size():
		if cell_i == j or not cells[j].active:
			continue
			
		var pos_j = cells[j].normalized_target_position
		var dist = pos_i.distance_to(pos_j)
		min_dist = min(min_dist, dist)
	
	return min_dist


func _adjust_weights(delta: float) -> void:
	for it in weight_adjustment_iterations:
		for i in cells.size():
			var area_ratio = float(cells.size()) * cells[i].polygon_area_ratio
			var goal_ratio = 1.0
			var weight_diff = (goal_ratio - area_ratio) * weight_adjustment_rate * delta
			
			cells[i].weight += weight_diff
		
		_center_weights()
		_generate_polygons()


func _center_weights():
	var average = 0.0
	for i in cells.size():
		average += cells[i].weight
	average /= cells.size()
	
	for i in cells.size():
		cells[i].weight -= average


func _create_viewport(index: int) -> void:
	var viewport = _splitscreen_sub_viewport_scene.instantiate()
	viewport.name = "SubViewport" + str(index)
	viewport.size = size
	viewport.world_2d = cells[index].target.get_world_2d()
	viewport.snap_2d_transforms_to_pixel = snap_2d_transforms_to_pixel
	add_child(viewport)
	
	cells[index].viewport = viewport 
	cells[index].camera = viewport.camera


func _update_cameras(delta: float) -> void:
	# Compute camera targets
	for i in cells.size():
		var camera: Camera2D = cells[i].camera
		var sub_viewport: SplitscreenSubViewport = cells[i].viewport
		
		camera.anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER
		camera.zoom = Vector2.ONE * default_camera_zoom
		
		var avg_target_pos = _get_cluster_target_average_position(cells[i].merged_with)
		var avg_center = cells[i].average_normalized_merge_position * size
		
		var screen_center = Vector2(sub_viewport.size) * 0.5
		var camera_offset = (screen_center - avg_center) / camera.zoom
		
		for j in cells[i].merged_with:
			cells[j].set_camera_target_position(avg_target_pos + camera_offset)
		
