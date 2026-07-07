extends PlayerState

@export var default_knockback = 1000.0

@export var visuals: StackedAnimatedSprite
@export var duration = 0.4
@export var star_angle_rotation_speed = 2.0
@export var slow_mo = 0.1

@export var damage_star: Star2D
@export var damage_star_2: Star2D
var damage_stars: bool = false

var time = 0.0
var star_angle = 0.0

var damager: Entity
var knockback_dir: Vector2

func _ready() -> void:
	super()
	
	damage_stars = damage_star and damage_star_2
	if damage_stars:
		damage_star.hide()
		damage_star_2.hide()
	

func _on_enter_state(params: Dictionary = {}):
	super(params)
	
	time = duration
	visuals.play("damaged")
	visuals.shake(3.0)
	
	if $"../../CapturerComponent".captured_entity:
		$"../../CapturerComponent".uncapture(player.aim_direction)
	
	if damage_stars:
		for star in [damage_star, damage_star_2]:
			var tween = get_tree().create_tween()
			star.show()
			star.seed = randf_range(0, 10000000)
			star.scale = Vector2.ZERO
			tween.tween_property(star, "scale", Vector2.ONE, 0.02)
			
			if params.has("damager"):
				if params["damager"].get_parent() is Entity:
					damager = params["damager"].get_parent()
					knockback_dir = player.global_position.direction_to(damager.global_position)
				star.rotation = player.global_position.direction_to(params["damager"].global_position).angle()
			
		star_angle = randf_range(0, TAU)

func _on_exit_state():
	super()
	
	if damage_stars:
		for star in [damage_star, damage_star_2]:
			var tween = get_tree().create_tween()
			tween.tween_property(star, "scale", Vector2.ZERO, 0.05)
			tween.tween_callback(star.hide)
	
	if damager:
		player.apply_impulse(-knockback_dir * default_knockback)

func _process(delta: float) -> void:
	super(delta)
	
	if damage_stars:
		star_angle += delta * star_angle_rotation_speed
		
		for star in [damage_star, damage_star_2]:
			star.min_start_angle = fmod(star_angle, TAU) 
			star.max_start_angle = fmod(star_angle, TAU) 
			
			star.generate()
			star.show()

func _physics_process(delta: float) -> void:
	super(delta)
	
	time -= delta
	if time <= 0.0:
		state_machine.set_state("Idle")
