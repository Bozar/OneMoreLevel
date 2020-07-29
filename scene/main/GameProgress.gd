extends Node2D
class_name Game_GameProgress


var _new_InitWorldData := preload("res://library/InitWorldData.gd").new()
var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()

var _progress: Game_ProgressTemplate


func _on_InitWorld_world_selected(new_world: String) -> void:
	_progress = _new_InitWorldData.get_progress(new_world).new(self)


func _on_Schedule_turn_started(current_sprite: Sprite) -> void:
	if current_sprite.is_in_group(_new_SubGroupTag.PC):
		_progress.renew_world()


func _on_RemoveObject_sprite_removed(remove_sprite: Sprite,
		main_group: String, x: int, y: int) -> void:
	if main_group == _new_MainGroupTag.ACTOR:
		_progress.remove_npc(remove_sprite, x, y)
	elif main_group == _new_MainGroupTag.BUILDING:
		_progress.remove_building(remove_sprite, x, y)
