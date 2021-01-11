extends Node2D
class_name Game_PlayerInput


const RELOAD_GAME: String = "ReloadGame"

var _ref_Schedule: Game_Schedule
var _ref_DungeonBoard: Game_DungeonBoard
var _ref_RemoveObject: Game_RemoveObject
var _ref_ObjectData: Game_ObjectData
var _ref_RandomNumber: Game_RandomNumber
var _ref_DangerZone: Game_DangerZone
var _ref_SwitchSprite: Game_SwitchSprite
var _ref_EndGame: Game_EndGame
var _ref_CountDown: Game_CountDown
var _ref_SwitchScreen: Game_SwitchScreen
var _ref_CreateObject : Game_CreateObject

var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_WorldTag := preload("res://library/WorldTag.gd").new()
var _new_InputTag := preload("res://library/InputTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_SpriteTypeTag := preload("res://library/SpriteTypeTag.gd").new()
var _new_Palette := preload("res://library/Palette.gd").new()
var _new_InitWorldData := preload("res://library/InitWorldData.gd").new()
var _new_ScreenTag: = preload("res://library/ScreenTag.gd").new()

var _pc_action: Game_PCActionTemplate
var _direction: String
var _end_game: bool = false
var _is_wizard: bool

var _move_inputs: Array = [
	_new_InputTag.MOVE_LEFT,
	_new_InputTag.MOVE_RIGHT,
	_new_InputTag.MOVE_UP,
	_new_InputTag.MOVE_DOWN,
]


func _ready() -> void:
	set_process_unhandled_input(false)


func _unhandled_input(event: InputEvent) -> void:
	_pc_action.reset_state()

	if _is_quit_input(event):
		get_tree().quit()
		return

	if _is_force_reload_input(event):
		get_node(RELOAD_GAME).reload()
		return

	if _end_game:
		if _is_reload_input(event):
			get_node(RELOAD_GAME).reload()
		return

	if _is_wizard:
		if _is_add_turn_input(event):
			_ref_CountDown.add_count(1)
		elif _is_fully_restore_turn_input(event):
			_ref_CountDown.add_count(99)

	_pc_action.set_source_position()
	if _is_move_input(event):
		_handle_move_input()
	elif _is_wait_input(event):
		_pc_action.wait()
	elif _is_help_input(event):
		_ref_SwitchScreen.switch_to_screen(_new_ScreenTag.HELP)

	# Do not end PC's turn if game ends.
	if _end_game:
		return

	if _pc_action.end_turn:
		set_process_unhandled_input(false)
		_ref_Schedule.end_turn()


# Refer: PCActionTemplate.gd.
func _on_InitWorld_world_selected(new_world: String) -> void:
	_pc_action = _new_InitWorldData.get_pc_action(new_world).new(self)


func _on_CreateObject_sprite_created(new_sprite: Sprite) -> void:
	if new_sprite.is_in_group(_new_SubGroupTag.PC):
		set_process_unhandled_input(true)


func _on_Schedule_turn_started(current_sprite: Sprite) -> void:
	if not current_sprite.is_in_group(_new_SubGroupTag.PC):
		return

	_pc_action.switch_sprite()
	if not _pc_action.allow_input():
		_pc_action.pass_turn()
		_ref_Schedule.end_turn()
	else:
		set_process_unhandled_input(true)


func _on_EndGame_game_is_over(win: bool) -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if not win:
		pc.modulate = _new_Palette.SHADOW

	_end_game = true
	set_process_unhandled_input(true)


func _on_GameSetting_setting_loaded(
		setting: Game_GameSetting.PlayerSetting) -> void:
	_is_wizard = setting.wizard_mode


func _on_SwitchScreen_screen_switched(screen_tag: String) -> void:
	set_process_unhandled_input(screen_tag == _new_ScreenTag.MAIN)


func _is_reload_input(event: InputEvent) -> bool:
	return event.is_action_pressed(_new_InputTag.RELOAD)


func _is_force_reload_input(event: InputEvent) -> bool:
	return event.is_action_pressed(_new_InputTag.FORCE_RELOAD)


func _is_wait_input(event: InputEvent) -> bool:
	return event.is_action_pressed(_new_InputTag.WAIT)


func _is_move_input(event: InputEvent) -> bool:
	for m in _move_inputs:
		if event.is_action_pressed(m):
			_direction = m
			return true
	_direction = ""
	return false


func _handle_move_input() -> void:
	_pc_action.set_target_position(_direction)
	if not _pc_action.is_inside_dungeon():
		return

	if _pc_action.is_npc():
		_pc_action.attack()
	elif _pc_action.is_building():
		_pc_action.interact_with_building()
	elif _pc_action.is_trap():
		_pc_action.interact_with_trap()
	else:
		_pc_action.move()


func _is_add_turn_input(event: InputEvent) -> bool:
	return event.is_action_pressed(_new_InputTag.ADD_TURN)


func _is_fully_restore_turn_input(event: InputEvent) -> bool:
	return event.is_action_pressed(_new_InputTag.FULLY_RESTORE_TURN)


func _is_quit_input(event: InputEvent) -> bool:
	return event.is_action_pressed(_new_InputTag.QUIT)


func _is_help_input(event: InputEvent) -> bool:
	return event.is_action_pressed(_new_InputTag.HELP)
