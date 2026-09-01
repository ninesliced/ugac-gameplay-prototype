@abstract
extends Node
class_name AbstractState

signal enter_state
signal exit_state

func _on_enter_state(params: Dictionary = {}):
	pass

func _on_exit_state():
	pass
