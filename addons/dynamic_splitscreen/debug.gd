extends Node2D

@export var distance_debug = true
@export var minimap_debug = true

var default_font: Font

func _ready() -> void:
	default_font = ThemeDB.fallback_font
	set_process(true)
	z_index = 100 

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	#var splitter = get_parent()
	#var num_cells: int = splitter.number_of_cells
	#var cells: Dictionary = splitter.cells
	#for i in range(num_cells):
		#draw_rect(cells[i].bounding_box, Color.WHITE, false)
	#if distance_debug:
		#_draw_distance_debug()
	if minimap_debug:
		_draw_minimap_debug()

func _draw_distance_debug() -> void:
	var splitter = get_parent()
	
	if not "cells" in splitter or not "number_of_cells" in splitter:
		return
		
	var num_cells: int = splitter.number_of_cells
	var cells: Dictionary = splitter.cells
	
	for i in range(num_cells):
		for j in range(i + 1, num_cells):
			if not cells.has(i) or not cells.has(j):
				continue
				
			var pos_a: Vector2 = (cells[i].target.global_position - cells[i].camera.global_position + splitter.size*0.5)
			var pos_b: Vector2 = (cells[j].target.global_position - cells[j].camera.global_position + splitter.size*0.5)
			
			draw_line(pos_a, pos_b, Color(1.0, 1.0, 1.0, 0.4), 2.0, true)
			
			#var distance: float = cells[i].target.global_position.distance_to(cells[j].target.global_position)
			#var distance: float = cells[i].polygon_center.distance_to(cells[j].polygon_center)
			var target_distance: float = cells[i].target.global_position.distance_to(cells[j].target.global_position)
			var center_distance: float = cells[i].polygon_center.distance_to(cells[j].polygon_center)
			var polygon_center_dist: float = cells[i].normalized_target_position.distance_to(cells[j].normalized_target_position)
			var mid_point := (pos_a + pos_b) / 2.0
			
			draw_string(
				default_font, 
				mid_point, 
				#"center: %s / target: %s / polygon_center dist: %s" % [str(snappedf(center_distance, 0.1)), str(snappedf(target_distance, 0.1)), str(snappedf(polygon_center_dist, 0.1))], 
				"polygon_center_dist: %s" % [str(snappedf(polygon_center_dist, 0.001))], 
				HORIZONTAL_ALIGNMENT_CENTER, 
				-1, 
				6, # Font size
				Color.GREEN_YELLOW
			)

func _draw_minimap_debug():
	var offset = Vector2(10.0, 10.0)
	var size = Vector2(300.0, 300.0)
	var num_cells: int = get_parent().number_of_cells
	var cells: Dictionary[int, SplitscreenCell] = get_parent().cells
	
	draw_rect(Rect2(offset, size), Color.WHITE, false, 1)
	
	for i in range(num_cells):
		var scaled_polygon = PackedVector2Array(cells[i].normalized_polygon)
		for j in scaled_polygon.size():
			scaled_polygon[j] = offset + size*scaled_polygon[j]
		if scaled_polygon.size() >= 3:
			draw_polyline(scaled_polygon, cells[cells[i].merge_parent].color)
			draw_polygon(scaled_polygon, [Color(cells[cells[i].merge_parent].color, 0.3)])
	
	for i in range(num_cells):
		draw_circle( offset + size*cells[i].average_normalized_merge_position, 6, Color(cells[cells[i].merge_parent].color, 0.3), true)
	
	for i in range(num_cells):
		draw_circle( offset + size*cells[i].normalized_polygon_center, 3, Color(cells[cells[i].merge_parent].color, 0.3), true)
		draw_string( ThemeDB.fallback_font, offset + size*cells[i].normalized_polygon_center+ Vector2.UP * 20 , str(round(cells[i].polygon_area_ratio * 1000)* 0.1) + "%")
	
