class_name WaveIndicatorLabel
extends Label

var tween: Tween

var focused: bool = false

#const unfocused_min_width = 100.0
const unfocused_min_width = 120.0
const focused_min_width = 330.0

const unfocused_scale = 0.5
const focused_scale = 1.0

const font_size = 150

func _ready() -> void:
	label_settings = label_settings.duplicate()
	label_settings.font_size = font_size
	
	custom_minimum_size.x = unfocused_min_width


func focus():
	focused = true
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)

	tween.tween_property(self, "offset_transform_scale", Vector2.ONE * focused_scale, 0.5)
	tween.parallel().tween_property(self, "custom_minimum_size:x", focused_min_width, 0.5)


func unfocus():
	focused = false
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)

	tween.tween_property(self, "offset_transform_scale", Vector2.ONE * unfocused_scale, 0.5)
	tween.parallel().tween_property(self, "custom_minimum_size:x", unfocused_min_width, 0.5)
