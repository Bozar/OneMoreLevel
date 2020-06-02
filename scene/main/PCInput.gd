extends Node2D


const RELOAD_GAME: String = "ReloadGame"

var _new_InputName := preload("res://library/InputName.gd").new()
var _new_SubGroupName := preload("res://library/SubGroupName.gd").new()

var _pc: Sprite
var _move_inputs: Array = [
	_new_InputName.MOVE_LEFT,
	_new_InputName.MOVE_RIGHT,
	_new_InputName.MOVE_UP,
	_new_InputName.MOVE_DOWN,
]


func _ready() -> void:
	set_process_unhandled_input(false)


func _unhandled_input(event: InputEvent) -> void:
	if _is_move_input(event):
		print("move")
	elif _is_reload_input(event):
		get_node(RELOAD_GAME).reload()


func _on_InitWorld_sprite_created(new_sprite: Sprite) -> void:
	if new_sprite.is_in_group(_new_SubGroupName.PC):
		_pc = new_sprite
		set_process_unhandled_input(true)


func _on_Schedule_turn_started(current_sprite: Sprite) -> void:
	if current_sprite.is_in_group(_new_SubGroupName.PC):
		set_process_unhandled_input(true)


func _is_reload_input(event: InputEvent) -> bool:
	if event.is_action_pressed(_new_InputName.RELOAD):
		return true
	return false


func _is_move_input(event: InputEvent) -> bool:
	for m in _move_inputs:
		if event.is_action_pressed(m):
			return true
	return false
