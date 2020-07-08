extends Node2D


const PCActionTemplate := preload("res://library/pc_action/PCActionTemplate.gd")
const DemoPCAction := preload("res://library/pc_action/DemoPCAction.gd")
const Schedule := preload("res://scene/main/Schedule.gd")
const DungeonBoard := preload("res://scene/main/DungeonBoard.gd")
const RemoveObject := preload("res://scene/main/RemoveObject.gd")

const RELOAD_GAME: String = "ReloadGame"

var _ref_Schedule: Schedule
var _ref_DungeonBoard: DungeonBoard
var _ref_RemoveObject: RemoveObject

var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_WorldTag := preload("res://library/WorldTag.gd").new()
var _new_InputTag := preload("res://library/InputTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()

var _pc: Sprite
var _pc_action: PCActionTemplate
var _direction: String

var _move_inputs: Array = [
	_new_InputTag.MOVE_LEFT,
	_new_InputTag.MOVE_RIGHT,
	_new_InputTag.MOVE_UP,
	_new_InputTag.MOVE_DOWN,
]

var _select_world: Dictionary = {
	_new_WorldTag.DEMO: DemoPCAction,
	_new_WorldTag.KNIGHT: DemoPCAction,
}


func _ready() -> void:
	set_process_unhandled_input(false)


func _unhandled_input(event: InputEvent) -> void:
	_pc_action.reset_state()

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
	_pc_action = _select_world[new_world].new(
			_ref_DungeonBoard, _ref_RemoveObject)


func _on_InitWorld_sprite_created(new_sprite: Sprite) -> void:
	if new_sprite.is_in_group(_new_SubGroupTag.PC):
		_pc = new_sprite
		set_process_unhandled_input(true)


func _on_Schedule_turn_started(current_sprite: Sprite) -> void:
	if current_sprite.is_in_group(_new_SubGroupTag.PC):
		set_process_unhandled_input(true)


func _is_reload_input(event: InputEvent) -> bool:
	return event.is_action_pressed(_new_InputTag.RELOAD)


func _is_wait_input(event: InputEvent) -> bool:
	return event.is_action_pressed(_new_InputTag.WAIT)


func _is_move_input(event: InputEvent) -> bool:
	for m in _move_inputs:
		if event.is_action_pressed(m):
			_direction = m
			return true
	_direction = ""
	return false


func _handle_move_input() -> void:
	var source: Array = _new_ConvertCoord.vector_to_array(_pc.position)

	if _pc_action.is_ground(source, _direction):
		_pc_action.move()
	elif _pc_action.is_npc(source, _direction):
		_pc_action.attack()
	elif _pc_action.is_building(source, _direction):
		_pc_action.interact()
