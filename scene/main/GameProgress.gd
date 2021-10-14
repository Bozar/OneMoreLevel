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
var _ref_Palette: Game_Palette

var _progress: Game_ProgressTemplate
var _game_over: bool = false


func _on_InitWorld_world_selected(new_world: String) -> void:
	_progress = Game_InitWorldData.get_progress(new_world).new(self)


func _on_CreateObject_sprite_created(new_sprite: Sprite,
		main_tag: String, sub_tag: String, x: int, y: int) -> void:
	if main_tag == Game_MainTag.ACTOR:
		_progress.create_actor(new_sprite, sub_tag, x, y)
	elif main_tag == Game_MainTag.BUILDING:
		_progress.create_building(new_sprite, sub_tag, x, y)
	elif main_tag == Game_MainTag.TRAP:
		_progress.create_trap(new_sprite, sub_tag, x, y)


func _on_Schedule_turn_started(current_sprite: Sprite) -> void:
	var pc_pos: Game_IntCoord

	if current_sprite.is_in_group(Game_SubTag.PC):
		pc_pos = Game_ConvertCoord.vector_to_coord(current_sprite.position)
		_progress.renew_world(pc_pos.x, pc_pos.y)


func _on_Schedule_turn_ended(current_sprite: Sprite) -> void:
	var pc_pos: Game_IntCoord

	# Do not change world (like adding new NPCs) when the game is over.
	if _game_over:
		return
	if current_sprite.is_in_group(Game_SubTag.PC):
		pc_pos = Game_ConvertCoord.vector_to_coord(current_sprite.position)
		_progress.end_world(pc_pos.x, pc_pos.y)


func _on_RemoveObject_sprite_removed(remove_sprite: Sprite,
		main_tag: String, x: int, y: int) -> void:
	if main_tag == Game_MainTag.ACTOR:
		_progress.remove_actor(remove_sprite, x, y)
	elif main_tag == Game_MainTag.BUILDING:
		_progress.remove_building(remove_sprite, x, y)
	elif main_tag == Game_MainTag.TRAP:
		_progress.remove_trap(remove_sprite, x, y)


func _on_EndGame_game_over(win: bool) -> void:
	_game_over = true
	_progress.game_over(win)
