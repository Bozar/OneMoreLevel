class_name Game_ProgressTemplate


var _ref_RandomNumber: Game_RandomNumber
var _ref_Schedule: Game_Schedule
var _ref_CreateObject: Game_CreateObject
var _ref_RemoveObject: Game_RemoveObject
var _ref_DungeonBoard: Game_DungeonBoard
var _ref_SwitchSprite: Game_SwitchSprite
var _ref_ObjectData: Game_ObjectData
var _ref_DangerZone: Game_DangerZone
var _ref_EndGame: Game_EndGame
var _ref_Palette: Game_Palette

var _spr_Floor := preload("res://sprite/Floor.tscn")


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
	_ref_Palette = parent_node._ref_Palette


# PC's FOV is rendered when his turn starts. Be careful of adding new sprites.
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


func create_actor(_actor: Sprite, _sub_tag: String, _x: int, _y: int) -> void:
	pass


func create_building(_building: Sprite, _sub_tag: String, _x: int, _y: int) \
		-> void:
	pass


func create_trap(_trap: Sprite, _sub_tag: String, _x: int, _y: int) -> void:
	pass


func game_over(_win: bool) -> void:
	pass


func _add_or_remove_ground(add_ground: bool, x: int, y: int,
		new_sprite: PackedScene = _spr_Floor,
		sub_tag: String = Game_SubTag.FLOOR) -> void:
	if add_ground:
		_ref_CreateObject.create_ground(new_sprite, sub_tag, x, y)
	else:
		_ref_RemoveObject.remove_ground(x, y)
