extends Node2D


const PCActionTemplate := preload("res://library/pc_action/PCActionTemplate.gd")
const DemoPCAction := preload("res://library/pc_action/DemoPCAction.gd")
const Schedule := preload("res://scene/main/Schedule.gd")

const RELOAD_GAME: String = "ReloadGame"

var _ref_Schedule: Schedule

var _new_WorldName := preload("res://library/WorldName.gd").new()
var _new_InputName := preload("res://library/InputName.gd").new()
var _new_SubGroupName := preload("res://library/SubGroupName.gd").new()

var _pc: Sprite
var _pc_action: PCActionTemplate
var _direction: String
var _move_inputs: Array = [
	_new_InputName.MOVE_LEFT,
	_new_InputName.MOVE_RIGHT,
	_new_InputName.MOVE_UP,
	_new_InputName.MOVE_DOWN,
]


func _ready() -> void:
	set_process_unhandled_input(false)


func _unhandled_input(event: InputEvent) -> void:
	_pc_action.reset_status()

	if _is_move_input(event):
		_handle_move_input()
	elif _is_wait_input(event):
		_pc_action.wait()
	elif _is_reload_input(event):
		get_node(RELOAD_GAME).reload()

	if _pc_action.end_turn:
		set_process_unhandled_input(false)
		_ref_Schedule.end_turn()


func _on_InitWorld_world_selected(new_world: String) -> void:
	if new_world == _new_WorldName.DEMO:
		_pc_action = DemoPCAction.new()


func _on_InitWorld_sprite_created(new_sprite: Sprite) -> void:
	if new_sprite.is_in_group(_new_SubGroupName.PC):
		_pc = new_sprite
		set_process_unhandled_input(true)


func _on_Schedule_turn_started(current_sprite: Sprite) -> void:
	if current_sprite.is_in_group(_new_SubGroupName.PC):
		set_process_unhandled_input(true)


func _is_reload_input(event: InputEvent) -> bool:
	return event.is_action_pressed(_new_InputName.RELOAD)


func _is_wait_input(event: InputEvent) -> bool:
	return event.is_action_pressed(_new_InputName.WAIT)


func _is_move_input(event: InputEvent) -> bool:
	for m in _move_inputs:
		if event.is_action_pressed(m):
			_direction = m
			return true
	_direction = ""
	return false


func _handle_move_input() -> void:
	if _pc_action.is_ground(_direction):
		_pc_action.move()
	elif _pc_action.is_npc(_direction):
		_pc_action.attack()
	elif _pc_action.is_building(_direction):
		_pc_action.interact()
