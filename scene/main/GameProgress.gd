extends Node2D
class_name Game_GameProgress


var _ref_RandomNumber: Game_RandomNumber
var _ref_Schedule: Game_Schedule
var _ref_CreateObject : Game_CreateObject
var _ref_RemoveObject: Game_RemoveObject
var _ref_DungeonBoard: Game_DungeonBoard
var _ref_SwitchSprite: Game_SwitchSprite
var _ref_ObjectData: Game_ObjectData
var _ref_DangerZone: Game_DangerZone
var _ref_EndGame: Game_EndGame

var _new_InitWorldData := preload("res://library/InitWorldData.gd").new()
var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()

var _progress: Game_ProgressTemplate


func _on_InitWorld_world_selected(new_world: String) -> void:
	_progress = _new_InitWorldData.get_progress(new_world).new(self)


func _on_CreateObject_sprite_created(new_sprite: Sprite,
		main_group: String, sub_group: String, x: int, y: int) -> void:
	if main_group == _new_MainGroupTag.ACTOR:
		_progress.create_actor(new_sprite, sub_group, x, y)
	elif main_group == _new_MainGroupTag.BUILDING:
		_progress.create_building(new_sprite, sub_group, x, y)
	elif main_group == _new_MainGroupTag.TRAP:
		_progress.create_trap(new_sprite, sub_group, x, y)


func _on_Schedule_turn_started(current_sprite: Sprite) -> void:
	var _pc_pos: Array

	if current_sprite.is_in_group(_new_SubGroupTag.PC):
		_pc_pos = _new_ConvertCoord.vector_to_array(current_sprite.position)
		_progress.renew_world(_pc_pos[0], _pc_pos[1])


func _on_Schedule_turn_ended(current_sprite: Sprite) -> void:
	var _pc_pos: Array

	if current_sprite.is_in_group(_new_SubGroupTag.PC):
		_pc_pos = _new_ConvertCoord.vector_to_array(current_sprite.position)
		_progress.end_world(_pc_pos[0], _pc_pos[1])


func _on_RemoveObject_sprite_removed(remove_sprite: Sprite,
		main_group: String, x: int, y: int) -> void:
	if main_group == _new_MainGroupTag.ACTOR:
		_progress.remove_actor(remove_sprite, x, y)
	elif main_group == _new_MainGroupTag.BUILDING:
		_progress.remove_building(remove_sprite, x, y)
	elif main_group == _new_MainGroupTag.TRAP:
		_progress.remove_trap(remove_sprite, x, y)


func _on_EndGame_game_over(win: bool) -> void:
	_progress.game_over(win)
