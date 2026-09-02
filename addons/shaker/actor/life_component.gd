extends Node2D
class_name LifeComponent

signal life_changed(new_value: float)
signal healed(amount: float)
signal damaged(amount: float)
signal died

@export_range(0, 200, 0.2, "or_greater") var max_life = 10.0:
	set(value):
		max_life = value
		life = life

@export_range(0, 10, 0.1, "or_greater", "suffix:s") var damage_cooldown = 2.0

var life = 0.0:
	set(value):
		life = clamp(value, 0.0, max_life)
var cooldown_value: float = 0.0:
	set(value):
		cooldown_value = max(0.0, value)

func _ready() -> void:
	life = max_life

func _process(delta: float) -> void:
	cooldown_value = max(0.0, cooldown_value - delta)

##########

func set_life(value: float) -> void:
	life = value
	life_changed.emit(value)
	if life <= 0:
		died.emit()

func heal(amount: float) -> void:
	set_life(life + amount)
	healed.emit(amount)

func damage(amount: float, ignore_cooldown = false) -> void:
	if not ignore_cooldown and is_in_cooldown():
		return
	
	set_life(life - amount)
	damaged.emit(amount)
	
	if not ignore_cooldown:
		set_cooldown(damage_cooldown)

func is_in_cooldown() -> bool:
	return cooldown_value > 0

func set_cooldown(value: float) -> void:
	cooldown_value = value

func can_damage():
	return not is_in_cooldown()
