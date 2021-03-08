class_name Game_AITemplate


var print_text: String setget set_print_text, get_print_text

var _ref_ObjectData: Game_ObjectData
var _ref_DungeonBoard: Game_DungeonBoard
var _ref_SwitchSprite: Game_SwitchSprite
var _ref_DangerZone: Game_DangerZone
var _ref_EndGame: Game_EndGame
var _ref_RandomNumber: Game_RandomNumber
var _ref_RemoveObject : Game_RemoveObject
var _ref_CountDown : Game_CountDown
var _ref_CreateObject : Game_CreateObject
var _ref_Schedule: Game_Schedule

var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()
var _new_ObjectStateTag := preload("res://library/ObjectStateTag.gd").new()
var _new_SpriteTypeTag := preload("res://library/SpriteTypeTag.gd").new()
var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_Palette := preload("res://library/Palette.gd").new()
var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()
var _new_PathFindingData := preload("res://library/PathFindingData.gd").new()
var _new_DijkstraPathFinding := preload("res://library/DijkstraPathFinding.gd").new()
var _new_ArrayHelper := preload("res://library/ArrayHelper.gd").new()

var _self: Sprite
var _pc_pos: Array
var _self_pos: Array
var _target_pos: Array
var _dungeon: Dictionary


# Refer: EnemyAI.gd.
func _init(parent_node: Node2D) -> void:
	_ref_ObjectData = parent_node._ref_ObjectData
	_ref_DungeonBoard = parent_node._ref_DungeonBoard
	_ref_SwitchSprite = parent_node._ref_SwitchSprite
	_ref_DangerZone = parent_node._ref_DangerZone
	_ref_EndGame = parent_node._ref_EndGame
	_ref_RandomNumber = parent_node._ref_RandomNumber
	_ref_RemoveObject = parent_node._ref_RemoveObject
	_ref_CountDown = parent_node._ref_CountDown
	_ref_CreateObject = parent_node._ref_CreateObject
	_ref_Schedule = parent_node._ref_Schedule

	for x in range(_new_DungeonSize.MAX_X):
		_dungeon[x] = []
		_dungeon[x].resize(_new_DungeonSize.MAX_Y)


# Override.
func take_action() -> void:
	pass


# Override.
func remove_data(_actor: Sprite) -> void:
	pass


func get_print_text() -> String:
	return print_text


func set_print_text(_text: String) -> void:
	return


func set_local_var(actor: Sprite) -> void:
	var pc = _ref_DungeonBoard.get_pc()

	_self = actor
	_self_pos = _new_ConvertCoord.vector_to_array(_self.position)
	_pc_pos = _new_ConvertCoord.vector_to_array(pc.position)


func _approach_pc() -> void:
	var destination: Array

	_init_dungeon()
	_dungeon[_pc_pos[0]][ _pc_pos[1]] = _new_PathFindingData.DESTINATION
	_dungeon = _new_DijkstraPathFinding.get_map(_dungeon, [_pc_pos])

	destination = _new_DijkstraPathFinding.get_path(_dungeon,
			_self_pos[0], _self_pos[1],
			self, "_is_passable_func", [])

	if destination.size() > 0:
		_new_ArrayHelper.rand_picker(destination, 1, _ref_RandomNumber)
		_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR,
				_self_pos, destination[0])
		_target_pos = destination[0]


func _init_dungeon() -> void:
	for x in range(_new_DungeonSize.MAX_X):
		for y in range(_new_DungeonSize.MAX_Y):
			if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING, x, y):
				_dungeon[x][y] = _new_PathFindingData.OBSTACLE
			else:
				_dungeon[x][y] = _new_PathFindingData.UNKNOWN


func _is_passable_func(source_array: Array, current_index: int,
		_opt_arg: Array) -> bool:
	var x: int = source_array[current_index][0]
	var y: int = source_array[current_index][1]
	return not _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR, x, y)
