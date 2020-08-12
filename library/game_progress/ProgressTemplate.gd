class_name Game_ProgressTemplate


var _ref_RandomNumber: Game_RandomNumber
var _ref_Schedule: Game_Schedule
var _ref_CreateObject : Game_CreateObject
var _ref_DungeonBoard: Game_DungeonBoard

var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()
var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()


# Refer: GameProgress.gd.
func _init(parent_node: Node2D) -> void:
	_ref_RandomNumber = parent_node._ref_RandomNumber
	_ref_Schedule = parent_node._ref_Schedule
	_ref_CreateObject = parent_node._ref_CreateObject
	_ref_DungeonBoard = parent_node._ref_DungeonBoard


func renew_world(_pc_x: int, _pc_y: int) -> void:
	pass


func remove_npc(_npc: Sprite, _x: int, _y: int) -> void:
	pass


func remove_building(_building: Sprite, _x: int, _y: int) -> void:
	pass


func remove_trap(_trap: Sprite, _x: int, _y: int) -> void:
	pass
