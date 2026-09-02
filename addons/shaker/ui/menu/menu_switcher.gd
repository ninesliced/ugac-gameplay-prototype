class_name MenuSwitcher
extends Control

## UI Node that can contain multiple [Menu]s and switch between them.

## Emitted when this Switcher is opened.
signal opened

## Emitted when this Switcher is closed.
signal closed

## Default menu to load when this node is ready. Should be set 
## to [code]null[/code] if no default should be set.
@export var default_menu: Menu 

@export_subgroup("Back", "back_")
## Whether this switcher can back to a previous menu.
@export var back_enabled: bool = true
## The input action associated with back. 
@export var back_input_action: StringName = &"back"

var is_opened: bool = false
var current_menu: Menu = null

var _menu_stack: Array = []
var _menus: Dictionary[StringName, Menu] = {}


func _ready() -> void:
	_index_menus()
	if default_menu:
		switch_to_menu(default_menu.name)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(back_input_action):
		back()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		back()


## Whether the given menu exists in this MenuSwitcher.
func has_menu(name: StringName) -> bool:
	return _menus.has(name)


## Switches to the given [Menu], calling [member Menu.close] and [member Menu.open]
## on the respectively switched Menus.
func switch_to_menu(name: StringName, add_to_stack: bool = true) -> void:
	if not _menus.has(name):
		push_error("Menu %s doesn't exist in %s" % [name, self])
		return
	
	var menu = _menus[name]
	switch_to_menu_node(menu, add_to_stack)


## Identical to [method switch_to_menu], but is instead directly given a [Menu] Node.[br]
##
## Switches to the given [Menu], calling [member Menu.close] and [member Menu.open]
## on the respectively switched Menus.
func switch_to_menu_node(menu: Menu, add_to_stack: bool = true) -> void:
	if not is_instance_valid(menu):
		push_error("Given Menu %s is not a valid instance in %s" % [menu, self])
		return
	if not menu.get_parent() == self:
		push_error("Given Menu %s is not a child of %s" % [menu, self])
		return
	
	if is_instance_valid(current_menu):
		current_menu.leave()
	if not is_opened:
		open()
	
	if add_to_stack:
		_menu_stack.append(menu)
	current_menu = menu
	
	menu.enter()


## Moves back to the last previously set menu, if [code]add_to_stack[/code] wasn't 
## set when switching.
func back() -> void:
	if not is_opened:
		return
	
	var _closed_menu = _menu_stack.pop_back()
	
	if _menu_stack.is_empty():
		close()
		return
	
	var menu = _menu_stack.back()
	if is_instance_valid(menu):
		switch_to_menu_node(menu, false)


## Opens this Switcher.
func open():
	is_opened = true
	opened.emit()


## Closes this Switcher and clears [member current_menu] and the menu stack.
func close():
	is_opened = false
	
	current_menu.leave()
	current_menu = null
	
	_menu_stack.clear()
	closed.emit()


func _index_menus() -> void:
	for child in get_children():
		if child is Menu:
			_menus.set(child.name, child)
			child.hide()
