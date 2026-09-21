class_name WaveIndicatorHUD
extends Control

var tween: Tween

var wave_count = 9

@onready var background_panel: PanelContainer = %BackgroundPanel
@onready var border_top: TextureRect = %BorderTop
@onready var border_bottom: TextureRect = %BorderBottom
@onready var highlight_circle: TextureRect = %HighlightCircle
@onready var wave_indicator_label: InstancePlaceholder = %WaveIndicatorLabel
@onready var wave_indicator_separator_dot: InstancePlaceholder = $Numbers/WaveIndicatorSeparatorDot
@onready var numbers: HBoxContainer = %Numbers

const WAVE_INDICATOR_LABEL = preload("uid://cfl0pyno4kmqi")
const WAVE_INDICATOR_SEPARATOR_DOT = preload("uid://yjx5bfnvbv4w")

var labels: Array[WaveIndicatorLabel] = []

var focused_label: WaveIndicatorLabel
var focused_index = 0

func _ready() -> void:
	_generate_numbers()
	
	focused_label = labels[0]
	focused_label.focus()
	
	_init_circle.call_deferred()
	hide()


func _init_circle():
	var target = focused_label.position.x + focused_label.size.x/2 - highlight_circle.size.x/2
	highlight_circle.position.x = target


func set_wave_count(value: int):
	wave_count = value
	_generate_numbers()


func _generate_numbers():
	labels.clear()
	for child in numbers.get_children():
		child.queue_free()
	
	for i in wave_count:
		var label: WaveIndicatorLabel = WAVE_INDICATOR_LABEL.instantiate()
		label.text = str(i + 1)
		numbers.add_child(label)
		numbers.move_child(label, -1)
		
		if i < wave_count - 1:
			var dot: TextureRect = wave_indicator_separator_dot.create_instance()
			numbers.add_child(dot)
			numbers.move_child(dot, -1)
		
		labels.append(label)


func _init_tween():
	if tween: 
		tween.kill()
	
	tween = create_tween()


func open():
	_init_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	
	show()
	_init_circle.call_deferred()
	
	tween.parallel().tween_property(background_panel, "offset_transform_scale:y", 1.0, 0.4).from(0.0)
	tween.parallel().tween_property(numbers, "offset_transform_scale:y", 1, 0.4).from(0.0)
	tween.parallel().tween_property(highlight_circle, "offset_transform_scale", Vector2(1.0, 1.0), 0.4).from(Vector2(1.0, 0.0))


func close():
	_init_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	
	tween.parallel().tween_property(background_panel, "offset_transform_scale:y", 0.0, 0.4).from(1.0)
	tween.parallel().tween_property(numbers, "offset_transform_scale:y", 0.0, 0.4).from(1.0)
	tween.parallel().tween_property(highlight_circle, "offset_transform_scale", Vector2(1.0, 0.0), 0.4).from(Vector2.ONE)
	tween.tween_callback(hide)


func _input(event: InputEvent) -> void:
	return
	if event.is_action_pressed("ui_accept"):
		open()
	if event.is_action_pressed("ui_cancel"):
		close()
	if event.is_action_pressed("ui_left"):
		focus_on((focused_index - 1) % wave_count)
	if event.is_action_pressed("ui_right"):
		focus_on((focused_index + 1) % wave_count)


func focus_on(index: int):
	if focused_label:
		focused_label.unfocus()
	
	focused_index = index
	focused_label = labels[index]
	focused_label.focus()
	
	_init_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	var old_x = highlight_circle.position.x
	tween.tween_method(func(t: float):
		var target = focused_label.position.x + focused_label.size.x/2 - highlight_circle.size.x/2
		highlight_circle.position.x = lerp(old_x, target, t)
	, 0.0, 1.0, 0.5)
