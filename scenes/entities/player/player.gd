class_name Player
extends Actor

@export var block_inputs := false

@export_category("Imports")
@export var visuals: StackedAnimatedSprite
@export var vacuum_raycast: VacuumRaycast
@export var vacuum_particles: CPUParticles2D
@export var vacuum_dust_particles: CPUParticles2D
@export var capturer_component: CapturerComponent
@export var hitbox: Hitbox

@export_category("Vacuum")
@export var vacuum_range = 400
@export var vacuum_width = 40
@export var vacuum_visual_range_offset = 16
@export var vacuum_visual_width = 24
@export var vacuum_visual_particles_speed_min = 1000
@export var vacuum_visual_particles_speed_max = 1200

@export_category("Visuals")
@export var squash_speed = 4.0
@export var post_capture_squash = 1.5

var user_index = 0

var squash = 1.0

var walk_direction := Vector2.RIGHT
var aim_direction := Vector2.RIGHT
var aim_angle := 0.0

var splitscreen_cell: SplitscreenCell

func _ready() -> void:
	super()
	setup_vacuum_raycast()
	
	InputManager.user_removed.connect(_on_user_removed)
	
	hitbox.disable()

func setup_vacuum_raycast():
	vacuum_raycast.enabled = false
	vacuum_raycast.length = vacuum_range
	
	var visual_range = vacuum_range - vacuum_visual_range_offset
	vacuum_particles.position.x = visual_range
	vacuum_particles.emission_rect_extents.x = 8
	vacuum_particles.emission_rect_extents.y = vacuum_visual_width * 0.5
	vacuum_particles.initial_velocity_min = vacuum_visual_particles_speed_min
	vacuum_particles.initial_velocity_max = vacuum_visual_particles_speed_max
	vacuum_particles.lifetime = visual_range / vacuum_particles.initial_velocity_max
	vacuum_particles.emitting = false
	
	vacuum_dust_particles.emitting = false

func _process(delta: float) -> void:
	if not InputManager.user_exists(user_index):
		queue_free()
		return 
	
	if has_captured_entity():
		visuals.set_layer_visibility("FaceSprite", false)
		visuals.set_layer_visibility("FaceSpriteMouthFull", true)
	else:
		visuals.set_layer_visibility("FaceSprite", true)
		visuals.set_layer_visibility("FaceSpriteMouthFull", false)
	
	_update_aim_direction()
	
	squash = move_toward(squash, 1.0, squash_speed * delta)
	if abs(squash - 1.0) < 0.01:
		squash = 1.0
	visuals.scale = Vector2(squash, 1/squash)
	
	$ProgressBar.max_value = $LifeComponent.max_life
	$ProgressBar.value = $LifeComponent.life
	$Label.text = str($LifeComponent.life) + " / " + str($LifeComponent.max_life)

func _update_aim_direction():
	if block_inputs:
		set_aim_direction(Vector2.RIGHT)
		return
	
	if InputManager.supports_mouse(user_index):
		var mouse_pos: Vector2
		if splitscreen_cell:
			mouse_pos = await splitscreen_cell.get_mouse_pos()
		else:
			mouse_pos = get_global_mouse_position()
		var direction = (mouse_pos - global_position).normalized()
		set_aim_direction(direction)
	else:
		var direction = get_vector("game_left", "game_right", "game_up", "game_down")
		if not direction.is_zero_approx():
			set_aim_direction(direction.normalized())

func set_aim_direction(direction: Vector2):
	aim_direction = Vector2(direction).normalized()
	aim_angle = direction.angle()

func set_aim_angle(angle: float):
	set_aim_direction(Vector2.RIGHT.rotated(angle))

func has_captured_entity():
	return capturer_component.has_captured_entity()

func exhale():
	capturer_component.uncapture(aim_direction)
	state_machine.set_state("Spitting")

func _on_capturer_component_captured(new_captured_entity: Entity) -> void:
	state_machine.set_state("Idle")
	visuals.play("close_mouth")
	set_squash(post_capture_squash)

func set_squash(value: float):
	squash = value

func get_vector(negative_x: StringName, positive_x: StringName, negative_y: StringName, positive_y: StringName, deadzone: float = -1.0) -> Vector2:
	if block_inputs:
		return Vector2.ZERO
	return InputManager.get_vector(user_index, negative_x, positive_x, negative_y, positive_y, deadzone)

func is_action_just_pressed(action: StringName, exact_match: bool = false) -> bool:
	if block_inputs:
		return false
	return InputManager.is_action_just_pressed(user_index, action, exact_match)

func is_action_just_released(action: StringName, exact_match: bool = false) -> bool:
	if block_inputs:
		return false
	return InputManager.is_action_just_released(user_index, action, exact_match)

func _on_hurtbox_recieved_damage(area: Hitbox) -> void:
	if area.damage == 0:
		return
	state_machine.set_state("Damaged", {"damager": area})

func _on_user_removed(_user_index: int):
	if _user_index == user_index:
		queue_free()
