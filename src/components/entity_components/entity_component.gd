## Class representing a component for an Entity. 
## This class is delibirately minimalist; if needed, inherited classes 
## can implement "activate" and "deactivate" functions,
## that have to set active to true and false respectively. 
@abstract
class_name EntityComponent
extends Node2D

var active: bool = false
var entity: Entity

func _ready() -> void:
	assert(get_parent() is Entity, "Parent isn't an Entity")
	entity = get_parent()
