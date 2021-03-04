class_name Game_ProgressTemplate


var _ref_RandomNumber: Game_RandomNumber
var _ref_Schedule: Game_Schedule
var _ref_CreateObject : Game_CreateObject
var _ref_RemoveObject: Game_RemoveObject
var _ref_DungeonBoard: Game_DungeonBoard
var _ref_SwitchSprite: Game_SwitchSprite
var _ref_ObjectData: Game_ObjectData
var _ref_DangerZone: Game_DangerZone
var _ref_EndGame: Game_EndGame

var _spr_Floor := preload("res://sprite/Floor.tscn")

var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()
var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()
var _new_Palette := preload("res://library/Palette.gd").new()
var _new_SpriteTypeTag := preload("res://library/SpriteTypeTag.gd").new()
var _new_ObjectStateTag := preload("res://library/ObjectStateTag.gd").new()
var _new_ArrayHelper := preload("res://library/ArrayHelper.gd").new()


# Refer: GameProgress.gd.
func _init(parent_node: Node2D) -> void:
	_ref_RandomNumber = parent_node._ref_RandomNumber
	_ref_Schedule = parent_node._ref_Schedule
	_ref_CreateObject = parent_node._ref_CreateObject
	_ref_RemoveObject = parent_node._ref_RemoveObject
	_ref_DungeonBoard = parent_node._ref_DungeonBoard
	_ref_SwitchSprite = parent_node._ref_SwitchSprite
	_ref_ObjectData = parent_node._ref_ObjectData
	_ref_DangerZone = parent_node._ref_DangerZone
	_ref_EndGame = parent_node._ref_EndGame


func renew_world(_pc_x: int, _pc_y: int) -> void:
	pass


func end_world(_pc_x: int, _pc_y: int) -> void:
	pass


func remove_actor(_actor: Sprite, _x: int, _y: int) -> void:
	pass


func remove_building(_building: Sprite, _x: int, _y: int) -> void:
	pass


func remove_trap(_trap: Sprite, _x: int, _y: int) -> void:
	pass


func create_actor(_actor: Sprite, _sub_group: String, _x: int, _y: int) -> void:
	pass


func create_building(_building: Sprite, _sub_group: String,
		_x: int, _y: int) -> void:
	pass


func create_trap(_trap: Sprite, _sub_group: String, _x: int, _y: int) -> void:
	pass


func game_is_over(_win: bool) -> void:
	pass
