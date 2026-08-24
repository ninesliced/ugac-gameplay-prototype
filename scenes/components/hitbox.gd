## Area that can deal damage to Hurtboxes
@icon("./hitbox.svg")
extends Area2D
class_name Hitbox

@export var enabled: bool = true :
	set(value):
		enabled = value
		if enabled:
			_enable()
		else:
			_disable()
@export var damage: float = 1.0

signal sent_damage(hurtbox: Hurtbox)
signal on_hurt_box_hit(hurtbox: Hurtbox)

@export var damages_enemies: bool = false
@export var damages_players: bool = false

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _disable() -> void:
	monitoring = false

func _enable() -> void:
	monitoring = true

func disable() -> void:
	enabled = false
	_disable()

func enable() -> void:
	enabled = true
	_enable()

func _physics_process(delta: float) -> void:
	if not enabled:
		return
	
	var areas = get_overlapping_areas()
	
	for area in areas:
		if area is Hurtbox:
			var hurtbox = area as Hurtbox
			hurtbox.process_overlapping_hitbox(self)
			sent_damage.emit(hurtbox)
			on_hurt_box_hit.emit(hurtbox)

func _on_area_entered(area: Area2D):
	if not enabled:
		return
	
	if area is Hurtbox:
		var hurtbox = area as Hurtbox
		hurtbox.on_hitbox_entered(self)

func _on_area_exited(area: Area2D):
	if not enabled:
		return
	
	if area is Hurtbox:
		var hurtbox = area as Hurtbox
		hurtbox.on_hitbox_exited(self)
