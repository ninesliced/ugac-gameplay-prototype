extends EjectedState

func _on_enter_state(params: Dictionary = {}):
	super(params)


func _on_hitbox_on_hurtbox_hit(hurtbox: Hurtbox) -> void:
	if entity.is_nest_mergeable and hurtbox.owner is Nest:
		var nest = hurtbox.owner as Nest
		nest.add_egg(entity)
