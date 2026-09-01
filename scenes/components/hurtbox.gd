## Area that can recieve damage from hitboxes.
@icon("./hurtbox.svg")
extends Area2D
class_name Hurtbox

## Whether to ignore sibling hitboxes. 
@export var ignore_sibling_hitboxes := true

## Emitted when entered in collision with a hitbox.
signal hitbox_entered(area: Hitbox)
signal hitbox_exited(area: Hitbox)


func on_hitbox_entered(hitbox: Hitbox):
	if not is_hittable(hitbox):
		return
	
	hitbox_entered.emit(hitbox)


func process_overlapping_hitbox(hitbox: Hitbox):
	pass


func on_hitbox_exited(hitbox: Hitbox):
	hitbox_exited.emit(hitbox)


func is_hittable(hitbox: Hitbox):
	if ignore_sibling_hitboxes and hitbox.get_parent() == get_parent():
		return false
	return true
