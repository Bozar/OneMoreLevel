class_name Game_AITemplate


const DIJKSTRA: String = "res://library/npc_ai/DijkstraPathFinding.gd"

var print_text: String setget set_print_text, get_print_text

var _ref_ObjectData: Game_ObjectData
var _ref_DungeonBoard: Game_DungeonBoard
var _ref_SwitchSprite: Game_SwitchSprite
var _ref_DangerZone: Game_DangerZone
var _ref_EndGame: Game_EndGame
var _ref_RandomNumber: Game_RandomNumber

var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()
var _new_ObjectStateTag := preload("res://library/ObjectStateTag.gd").new()
var _new_SpriteTypeTag := preload("res://library/SpriteTypeTag.gd").new()
var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_Palette := preload("res://library/Palette.gd").new()
var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()
var _new_PathFindingData := preload("res://library/PathFindingData.gd").new()

var _new_DijkstraPathFinding := preload(DIJKSTRA).new()

var _pc: Sprite
var _self: Sprite
var _pc_pos: Array
var _self_pos: Array
var _dungeon: Dictionary


# Refer: EnemyAI.gd.
func _init(parent_node: Node2D) -> void:
	_pc = parent_node._pc
	_ref_ObjectData = parent_node._ref_ObjectData
	_ref_DungeonBoard = parent_node._ref_DungeonBoard
	_ref_SwitchSprite = parent_node._ref_SwitchSprite
	_ref_DangerZone = parent_node._ref_DangerZone
	_ref_EndGame = parent_node._ref_EndGame
	_ref_RandomNumber = parent_node._ref_RandomNumber

	for x in range(_new_DungeonSize.MAX_X):
		_dungeon[x] = []
		_dungeon[x].resize(_new_DungeonSize.MAX_Y)


# Override.
func take_action(_actor: Sprite) -> void:
	pass


# Override.
func remove_data(_actor: Sprite) -> void:
	pass


func get_print_text() -> String:
	return print_text


func set_print_text(_text: String) -> void:
	return


func _set_local_var(actor: Sprite) -> void:
	_self = actor
	_pc_pos = _new_ConvertCoord.vector_to_array(_pc.position)
	_self_pos = _new_ConvertCoord.vector_to_array(_self.position)


func _init_dungeon() -> void:
	for x in range(_new_DungeonSize.MAX_X):
		for y in range(_new_DungeonSize.MAX_Y):
			if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING, x, y):
				_dungeon[x][y] = _new_PathFindingData.OBSTACLE
			else:
				_dungeon[x][y] = _new_PathFindingData.UNKNOWN
