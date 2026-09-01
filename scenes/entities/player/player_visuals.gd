@tool
class_name PlayerVisuals
extends Node2D

@export var flip_h: bool = false: set = _set_flip_h

@export var sprite_rotation: float = 0.0: set = _set_sprite_rotation
@export var default_sprite_offset = Vector2(0.0, -48.0)
@export var mouth_full: bool = false: set = set_mouth_full

var _playback: AnimationNodeStateMachinePlayback

@onready var player: Player = $".."
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var stacked_sprite: StackedAnimatedSprite = $Body/StackedAnimatedSprite
@onready var shadow: AnimatedSprite2D = $Shadow

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	animation_tree.active = true
	_playback = animation_tree["parameters/playback"]
	shadow.play()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_update_body_flip()
	$Label.text = ""
	$Label.text += str(mouth_full) + "\n"


func play(anim: String) -> void:
	#animation_player.play(anim, -1, custom_speed)
	_playback.travel(anim)


func set_layer_visibility(layer: StringName, visibility: bool) -> void:
	if stacked_sprite:
		stacked_sprite.set_layer_visibility(layer, visibility)
	else:
		push_warning("no stacked sprite")


func set_mouth_full(value: bool) -> void:
	mouth_full = value
	if value:
		set_layer_visibility("Face", false)
		set_layer_visibility("FaceMF", true)
	else:
		set_layer_visibility("Face", true)
		set_layer_visibility("FaceMF", false)


func _update_body_flip() -> void:
	# This specifically excludes the case where walk_direction.x == 0.
	if player.walk_direction.x < 0:
		stacked_sprite.flip_h = true
	if player.walk_direction.x > 0:
		stacked_sprite.flip_h = false


func _set_flip_h(value: bool) -> void:
	flip_h = value
	stacked_sprite.flip_h = value


func _set_sprite_rotation(value: float) -> void:
	sprite_rotation = value
	stacked_sprite.rotation = value
