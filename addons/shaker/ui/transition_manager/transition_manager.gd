extends CanvasLayer
@onready var animation_player = $AnimationPlayer

func change_scene(packed_scene: PackedScene, start="fade", end=null) -> void:
	animation_player.play(start)

	get_tree().change_scene_to_packed(packed_scene)

	await get_tree().process_frame
	if animation_player.is_playing():
		await animation_player.animation_finished

	if end:
		animation_player.play(end)
	else:
		animation_player.play_backwards(start)
