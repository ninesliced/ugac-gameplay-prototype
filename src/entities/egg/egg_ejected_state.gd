extends EjectedState

func _on_enter_state(params: Dictionary = {}):
	super(params)
	
	hitbox.on_hurtbox_hit.connect(_on_hitbox_on_hurtbox_hit)


func _on_hitbox_on_hurtbox_hit(hurtbox: Hurtbox) -> void:
	if entity.is_nest_mergeable and hurtbox.owner is Nest:
		var nest = hurtbox.owner as Nest
		nest.add_egg(entity)


func _on_exit_state() -> void:
	hitbox.on_hurtbox_hit.disconnect(_on_hitbox_on_hurtbox_hit)
