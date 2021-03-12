class_name Game_PCActionTemplate
# Scripts such as [DungeonType]PCAction.gd inherit this script.
# All functions except getters and setters can be overriden.
# The child should also implement _init() to pass arguments.


const INPUT_TAG := preload("res://library/InputTag.gd")
const OBJECT_STATE_TAG := preload("res://library/ObjectStateTag.gd")
const MAIN_GROUP_TAG := preload("res://library/MainGroupTag.gd")
const DUNGEON_SIZE := preload("res://library/DungeonSize.gd")

const SHOW_FULL_MAP: bool = false
# const SHOW_FULL_MAP: bool = true

const DIRECTION_TO_COORD: Dictionary = {
	INPUT_TAG.MOVE_UP: [0, -1],
	INPUT_TAG.MOVE_DOWN: [0, 1],
	INPUT_TAG.MOVE_LEFT: [-1, 0],
	INPUT_TAG.MOVE_RIGHT: [1, 0],
}
const VALID_MAIN_GROUPS: Array = [
	MAIN_GROUP_TAG.ACTOR,
	MAIN_GROUP_TAG.BUILDING,
	MAIN_GROUP_TAG.TRAP,
]

var message: String setget set_message, get_message
var end_turn: bool setget set_end_turn, get_end_turn

var _ref_DungeonBoard: Game_DungeonBoard
var _ref_RemoveObject: Game_RemoveObject
var _ref_ObjectData: Game_ObjectData
var _ref_RandomNumber: Game_RandomNumber
var _ref_EndGame: Game_EndGame
var _ref_CountDown: Game_CountDown
var _ref_SwitchSprite: Game_SwitchSprite
var _ref_CreateObject : Game_CreateObject
var _ref_DangerZone: Game_DangerZone

var _new_InputTag := preload("res://library/InputTag.gd").new()
var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()
var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_ObjectStateTag := preload("res://library/ObjectStateTag.gd").new()
var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()
var _new_SpriteTypeTag := preload("res://library/SpriteTypeTag.gd").new()
var _new_Palette := preload("res://library/Palette.gd").new()
var _new_ArrayHelper := preload("res://library/ArrayHelper.gd").new()

var _source_position: Array
var _target_position: Array
var _input_direction: String


# Refer: PlayerInput.gd.
func _init(parent_node: Node2D) -> void:
	_ref_DungeonBoard = parent_node._ref_DungeonBoard
	_ref_RemoveObject = parent_node._ref_RemoveObject
	_ref_ObjectData = parent_node._ref_ObjectData
	_ref_RandomNumber = parent_node._ref_RandomNumber
	_ref_EndGame = parent_node._ref_EndGame
	_ref_CountDown = parent_node._ref_CountDown
	_ref_SwitchSprite = parent_node._ref_SwitchSprite
	_ref_CreateObject = parent_node._ref_CreateObject
	_ref_DangerZone = parent_node._ref_DangerZone


func get_message() -> String:
	return message


func set_message(_message: String) -> void:
	pass


func allow_input() -> bool:
	if _is_checkmate():
		_ref_EndGame.player_lose()
		return false
	return true


func pass_turn() -> void:
	pass


func get_end_turn() -> bool:
	return end_turn


func set_end_turn(_end_turn: bool) -> void:
	pass


func is_inside_dungeon() -> bool:
	var x: int = _target_position[0]
	var y: int = _target_position[1]

	return _new_CoordCalculator.is_inside_dungeon(x, y)


func is_npc() -> bool:
	return _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR,
			_target_position[0], _target_position[1])


func is_building() -> bool:
	return _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING,
			_target_position[0], _target_position[1])


func is_trap() -> bool:
	return _ref_DungeonBoard.has_sprite(_new_MainGroupTag.TRAP,
			_target_position[0], _target_position[1])


func move() -> void:
	_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR,
			_source_position[0], _source_position[1],
			_target_position[0], _target_position[1])
	end_turn = true


func attack() -> void:
	_ref_RemoveObject.remove(_new_MainGroupTag.ACTOR,
			_target_position[0], _target_position[1])
	end_turn = true


func interact_with_building() -> void:
	pass


func interact_with_trap() -> void:
	pass


func wait() -> void:
	end_turn = true


func reset_state() -> void:
	end_turn = false


func set_source_position() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	_source_position = _new_ConvertCoord.vector_to_array(pc.position)


func set_target_position(direction: String) -> void:
	var shift: Array = DIRECTION_TO_COORD[direction]

	_target_position = [
		_source_position[0] + shift[0], _source_position[1] + shift[1]
	]
	_input_direction = direction


func render_fov() -> void:
	pass


func switch_sprite() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if _ref_DangerZone.is_in_danger(_source_position[0], _source_position[1]):
		_ref_SwitchSprite.switch_sprite(pc, _new_SpriteTypeTag.ACTIVE)
	else:
		_ref_SwitchSprite.switch_sprite(pc, _new_SpriteTypeTag.DEFAULT)


func game_over(win: bool) -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	_source_position = _new_ConvertCoord.vector_to_array(pc.position)
	render_fov()
	if not win:
		pc.modulate = _new_Palette.SHADOW


func _is_occupied(x: int, y: int) -> bool:
	if not _new_CoordCalculator.is_inside_dungeon(x, y):
		return true

	for i in VALID_MAIN_GROUPS:
		if _ref_DungeonBoard.has_sprite(i, x, y):
			return true
	return false


func _is_checkmate() -> bool:
	return false
