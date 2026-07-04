@tool
@icon("AnimatedSprite2D")
## Acts like an AnimatedSprite2D, but may contain mutliple layers, represented
## by its children.
class_name StackedAnimatedSprite
extends Node2D

## The AnimatedSprite2D used as a reference for all the other layers.
## All animation names and spritesheet image locations will be based off this 
## sprite.
@export var reference_sprite: AnimatedSprite2D

## A dictionary containing the texture that should be used for each layer, 
## except the reference one.
@export var sprite_name_to_texture: Dictionary[StringName, Texture2D]
@export_tool_button("Sync children", "Reload") var sync = _sync_children

## If true, texture is flipped horizontally.
@export var flip_h: bool = false:
	set(value):
		flip_h = value
		_run_for_all_children(func(spr: AnimatedSprite2D): spr.flip_h = value)

## If true, texture is flipped vertically.
@export var flip_v: bool = false:
	set(value):
		flip_v = value
		_run_for_all_children(func(spr: AnimatedSprite2D): spr.flip_v = value)

@export var offset: Vector2 = Vector2.ZERO:
	set(value):
		offset = value
		_run_for_all_nonref_children(func(spr: AnimatedSprite2D): spr.offset = reference_sprite.offset + value)
var reference_offset: Vector2 = Vector2.ZERO

@export var shake_decrease_speed = 30.0
var shake_amount = 0.0

#-----------------------------------------

## Emitted when animation changes.
signal animation_changed()

## Emitted when the animation reaches the end, or the start if it is played in reverse. When the animation finishes, it pauses the playback.
## Note: This signal is not emitted if an animation is looping.
signal animation_finished()

## Emitted when the animation loops.
signal animation_looped()

## Emitted when frame changes.
signal frame_changed()

## Emitted when sprite_frames changes.
signal sprite_frames_changed()

#-----------------------------------------

func _ready() -> void:
	assert(reference_sprite != null, "Reference Sprite is not defined")
	assert(sprite_name_to_texture != null, "'Sprite Name To Texture' dictionary is not defined")
	for child in get_children():
		assert(child is AnimatedSprite2D, "Node " + str(child.name) + " should be AnimatedSprite2D")
		if child.name != reference_sprite.name:
			assert(sprite_name_to_texture.has(child.name), "No entry in sprite_name_to_texture defined for " + str(child.name))
	
	reference_sprite.animation_changed.connect(func(): animation_changed.emit())
	reference_sprite.animation_finished.connect(func(): animation_finished.emit())
	reference_sprite.animation_looped.connect(func(): animation_looped.emit())
	reference_sprite.frame_changed.connect(func(): frame_changed.emit())
	reference_sprite.sprite_frames_changed.connect(func(): sprite_frames_changed.emit())
	
	reference_offset = reference_sprite.offset

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	shake_amount = max(0.0, shake_amount - delta * shake_decrease_speed)
	var shake_offset_x = randf_range(-shake_amount, shake_amount)
	var shake_offset_y = randf_range(-shake_amount, shake_amount)
	_run_for_all_children(
		func(spr: AnimatedSprite2D): 
			spr.offset = reference_offset + offset + Vector2(shake_offset_x, shake_offset_y)
	)

#-----------------------------------------

func set_layer_visibility(layer_name: String, visibility: bool):
	var node: Node2D = get_node_or_null(layer_name)
	assert(node != null, "Layer " + str(layer_name) + " doesn't exist")
	
	node.visible = visibility

func shake(value: float):
	shake_amount = value

#-----------------------------------------

## Plays the animation with key name. If custom_speed is negative and from_end is true, the animation will play backwards (which is equivalent to calling play_backwards()).
## 
## If this method is called with that same animation name, or with no name parameter, the assigned animation will resume playing if it was paused.
func play(name: StringName = &"", custom_speed: float = 1.0, from_end: bool = false):
	_run_for_all_children(func(spr: AnimatedSprite2D): spr.play(name, custom_speed, from_end))

func pause():
	_run_for_all_children(func(spr: AnimatedSprite2D): spr.pause())

func is_playing():
	return reference_sprite.is_playing()

#-----------------------------------------

func _run_for_all_children(f: Callable):
	for child in get_children():
		assert(child is AnimatedSprite2D)
		f.call(child as AnimatedSprite2D)
		
func _run_for_all_nonref_children(f: Callable):
	var fun = func(spr: AnimatedSprite2D):
		if spr == reference_sprite: 
			return
		f.call(spr)
	
	_run_for_all_children(fun)


func _sync_children():
	print("Syncing StackedAnimatedSprite children...")
	_run_for_all_children(func(spr: AnimatedSprite2D):
		if spr.name == reference_sprite.name:
			return
		
		print("- Syncing " + spr.name)
		spr.speed_scale = reference_sprite.speed_scale
		spr.centered = reference_sprite.centered
		spr.offset = reference_sprite.offset
		spr.flip_h = reference_sprite.flip_h
		spr.flip_v = reference_sprite.flip_v
		
		spr.sprite_frames = SpriteFrames.new()
		var tar_sf: SpriteFrames = spr.sprite_frames
		var ref_sf: SpriteFrames = reference_sprite.sprite_frames
		
		tar_sf.clear_all()
		for anim_name in ref_sf.get_animation_names():
			tar_sf.add_animation(anim_name)
			
			# Copy frames & properties
			for frame_i in range(ref_sf.get_frame_count(anim_name)):
				assert(sprite_name_to_texture.has(spr.name), "No texture defined for " + str(spr.name) + ".")
				var tar_texture: Texture2D = sprite_name_to_texture[spr.name]
				var texture: Texture2D
				var ref_texture = ref_sf.get_frame_texture(anim_name, frame_i)
				
				if ref_texture is AtlasTexture:
					texture = AtlasTexture.new()
					texture.atlas = tar_texture
					texture.filter_clip = ref_texture.filter_clip
					texture.margin = ref_texture.margin
					texture.region = ref_texture.region
				else:
					texture = tar_texture
				
				var duration = ref_sf.get_frame_duration(anim_name, frame_i)
				tar_sf.add_frame(anim_name, texture, duration)
			
			tar_sf.set_animation_loop(anim_name, ref_sf.get_animation_loop(anim_name))
			tar_sf.set_animation_speed(anim_name, ref_sf.get_animation_speed(anim_name))
		
		tar_sf.remove_animation(&"default")
	)
	print("Syncing StackedAnimatedSprite children done.")
