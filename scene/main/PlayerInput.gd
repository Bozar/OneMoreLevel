extends Node2D


const PCActionTemplate := preload("res://library/pc_action/PCActionTemplate.gd")
const Schedule := preload("res://scene/main/Schedule.gd")
const DungeonBoard := preload("res://scene/main/DungeonBoard.gd")
const ObjectData := preload("res://scene/main/ObjectData.gd")
const RemoveObject := preload("res://scene/main/RemoveObject.gd")
const RandomNumber := preload("res://scene/main/RandomNumber.gd")
const DangerZone := preload("res://scene/main/DangerZone.gd")
const SwitchSprite := preload("res://scene/main/SwitchSprite.gd")

const DemoPCAction := preload("res://library/pc_action/DemoPCAction.gd")
const KnightPCAction := preload("res://library/pc_action/KnightPCAction.gd")

const RELOAD_GAME: String = "ReloadGame"

var _ref_Schedule: Schedule
var _ref_DungeonBoard: DungeonBoard
var _ref_RemoveObject: RemoveObject
var _ref_ObjectData: ObjectData
var _ref_RandomNumber: RandomNumber
var _ref_DangerZone: DangerZone
var _ref_SwitchSprite: SwitchSprite

var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_WorldTag := preload("res://library/WorldTag.gd").new()
var _new_InputTag := preload("res://library/InputTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_SpriteTypeTag := preload("res://library/SpriteTypeTag.gd").new()
var _new_Palette := preload("res://library/Palette.gd").new()

var _pc: Sprite
var _pc_pos: Array
var _pc_action: PCActionTemplate
var _direction: String
var _pc_is_dead: bool = false
var _is_wizard: bool = true

var _move_inputs: Array = [
	_new_InputTag.MOVE_LEFT,
	_new_InputTag.MOVE_RIGHT,
	_new_InputTag.MOVE_UP,
	_new_InputTag.MOVE_DOWN,
]

var _select_world: Dictionary = {
	_new_WorldTag.DEMO: DemoPCAction,
	_new_WorldTag.KNIGHT: KnightPCAction,
}


func _ready() -> void:
	set_process_unhandled_input(false)


func _unhandled_input(event: InputEvent) -> void:
	_pc_action.reset_state()

	if _is_wizard:
		if _is_force_reload_input(event):
			get_node(RELOAD_GAME).reload()
			return

	if _pc_is_dead:
		if _is_reload_input(event):
			get_node(RELOAD_GAME).reload()
		return

	if _is_move_input(event):
		_handle_move_input()
	elif _is_wait_input(event):
		_pc_action.wait()

	if _pc_action.end_turn:
		set_process_unhandled_input(false)
		_ref_Schedule.end_turn()


# Refer: PCActionTemplate.gd.
func _on_InitWorld_world_selected(new_world: String) -> void:
	_pc_action = _select_world[new_world].new(self)


func _on_InitWorld_sprite_created(new_sprite: Sprite) -> void:
	if new_sprite.is_in_group(_new_SubGroupTag.PC):
		_pc = new_sprite
		_pc_pos = _new_ConvertCoord.vector_to_array(_pc.position)
		set_process_unhandled_input(true)


func _on_Schedule_turn_started(current_sprite: Sprite) -> void:
	if not current_sprite.is_in_group(_new_SubGroupTag.PC):
		return

	_pc_pos = _new_ConvertCoord.vector_to_array(_pc.position)

	if _ref_DangerZone.is_in_danger(_pc_pos[0], _pc_pos[1]):
		_ref_SwitchSprite.switch_sprite(_pc, _new_SpriteTypeTag.ACTIVE)
	else:
		_ref_SwitchSprite.switch_sprite(_pc, _new_SpriteTypeTag.DEFAULT)

	set_process_unhandled_input(true)


func _on_BuryPC_pc_is_dead() -> void:
	_pc_is_dead = true

	_ref_SwitchSprite.switch_sprite(_pc, _new_SpriteTypeTag.DEFAULT)
	_pc.modulate = _new_Palette.SHADOW

	set_process_unhandled_input(true)


func _is_reload_input(event: InputEvent) -> bool:
	return event.is_action_pressed(_new_InputTag.RELOAD)


func _is_force_reload_input(event: InputEvent) -> bool:
	return event.is_action_pressed(_new_InputTag.FORCE_RELOAD)


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
	if _pc_action.is_ground(_pc_pos, _direction):
		_pc_action.move()
	elif _pc_action.is_npc(_pc_pos, _direction):
		_pc_action.attack()
	elif _pc_action.is_building(_pc_pos, _direction):
		_pc_action.interact()
