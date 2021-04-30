extends Node2D
class_name Game_EnemyAI


signal enemy_warned(message)

var _ref_Schedule: Game_Schedule
var _ref_ObjectData: Game_ObjectData
var _ref_DungeonBoard: Game_DungeonBoard
var _ref_SwitchSprite: Game_SwitchSprite
var _ref_DangerZone: Game_DangerZone
var _ref_EndGame: Game_EndGame
var _ref_RandomNumber: Game_RandomNumber
var _ref_RemoveObject: Game_RemoveObject
var _ref_CountDown: Game_CountDown
var _ref_CreateObject : Game_CreateObject
var _ref_Palette: Game_Palette

var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_InitWorldData := preload("res://library/InitWorldData.gd").new()

var _world_tag: String
var _ai: Game_AITemplate


func _on_Schedule_turn_started(current_sprite: Sprite) -> void:
	if current_sprite.is_in_group(_new_SubGroupTag.PC):
		return

	_ai.set_local_var(current_sprite)
	_ai.take_action()
	if _ai.print_text != "":
		emit_signal("enemy_warned", _ai.print_text)
	_ref_Schedule.end_turn()


func _on_InitWorld_world_selected(new_world: String) -> void:
	_world_tag = new_world


func _on_CreateObject_sprite_created(_new_sprite: Sprite,
		_main_group: String, sub_group: String, _x: int, _y: int) -> void:
	if sub_group != _new_SubGroupTag.PC:
		return
	# Refer: AITemplate.gd.
	_ai = _new_InitWorldData.get_enemy_ai(_world_tag).new(self)


func _on_RemoveObject_sprite_removed(remove_sprite: Sprite,
		_main_group: String, _x: int, _y: int) -> void:
	_ai.remove_data(remove_sprite)
