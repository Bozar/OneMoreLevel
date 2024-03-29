extends Game_InputTemplate
class_name Game_PlayerInput


const RELOAD_GAME := "ReloadGame"
const BOTTOM_RIGHT_X := 21
const BOTTOM_RIGHT_Y := 15

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
var _ref_CreateObject: Game_CreateObject
var _ref_GameSetting: Game_GameSetting
var _ref_Palette: Game_Palette

var _pc_action: Game_PCActionTemplate
var _direction: String
var _end_game := false
var _world_tag: String


func _unhandled_input(event: InputEvent) -> void:
	var may_have_conflict := true

	if _verify_input(event, Game_InputTag.QUIT):
		get_tree().quit()
	elif _verify_input(event, Game_InputTag.FORCE_RELOAD) \
			or _is_mouse_force_reload(event):
		get_node(RELOAD_GAME).reload()
	elif _verify_input(event, Game_InputTag.REPLAY_WORLD):
		_ref_GameSetting.save_setting(Game_SaveTag.REPLAY_WORLD)
		get_node(RELOAD_GAME).reload()
	elif _verify_input(event, Game_InputTag.REPLAY_DUNGEON):
		_ref_GameSetting.save_setting(Game_SaveTag.REPLAY_DUNGEON)
		get_node(RELOAD_GAME).reload()
	elif _verify_input(event, Game_InputTag.COPY_SEED):
		OS.set_clipboard(_ref_RandomNumber.get_rng_seed() as String)
	elif _verify_input(event, Game_InputTag.COPY_WORLD):
		OS.set_clipboard(_world_tag)
	elif _verify_input(event, Game_InputTag.OPEN_HELP):
		_ref_SwitchScreen.set_screen(Game_ScreenTag.MAIN, Game_ScreenTag.HELP)
	elif _verify_input(event, Game_InputTag.OPEN_DEBUG):
		_ref_SwitchScreen.set_screen(Game_ScreenTag.MAIN, Game_ScreenTag.DEBUG)
	elif _end_game:
		if _verify_input(event, Game_InputTag.RELOAD) \
				or _is_mouse_action(event, Game_InputTag.RELOAD_BY_MOUSE):
			get_node(RELOAD_GAME).reload()
	else:
		may_have_conflict = false
	if may_have_conflict:
		return

	if _ref_GameSetting.get_wizard_mode():
		if _verify_input(event, Game_InputTag.ADD_TURN):
			_ref_CountDown.add_count(1)
		elif _verify_input(event, Game_InputTag.FULLY_RESTORE_TURN):
			_ref_CountDown.add_count(99)

	if _is_move_input(event) or _is_mouse_move_input(event):
		_handle_move_input()
	elif _verify_input(event, Game_InputTag.WAIT) \
			or _is_mouse_action(event, Game_InputTag.WAIT_BY_MOUSE):
		_handle_wait_input()

	# Do not end PC's turn if game ends.
	if _end_game:
		return
	if _pc_action.end_turn:
		set_process_unhandled_input(false)
		_ref_Schedule.end_turn()


# Refer: PCActionTemplate.gd.
func _on_InitWorld_world_selected(new_world: String) -> void:
	_pc_action = Game_InitWorldData.get_pc_action(new_world).new(self)
	_world_tag = Game_WorldTag.TAG_TO_NAME[new_world]


func _on_CreateObject_sprite_created(_new_sprite: Sprite, _main_tag: String,
		sub_tag: String, _x: int, _y: int, _layer: int) -> void:
	if sub_tag == Game_SubTag.PC:
		set_process_unhandled_input(true)


func _on_RemoveObject_sprite_removed(remove_sprite: Sprite, main_tag: String,
		x: int, y: int, _sprite_layer: int) -> void:
	_pc_action.remove_data(remove_sprite, main_tag, x, y)


func _on_Schedule_first_turn_started() -> void:
	_pc_action.init_data()


func _on_Schedule_turn_started(current_sprite: Sprite) -> void:
	if not current_sprite.is_in_group(Game_SubTag.PC):
		return

	_pc_action.set_source_position()
	_pc_action.reset_state()
	_pc_action.switch_sprite()
	_pc_action.render_fov()
	if not _pc_action.allow_input():
		_pc_action.pass_turn()
		_ref_Schedule.end_turn()
	else:
		set_process_unhandled_input(true)


func _on_EndGame_game_over(win: bool) -> void:
	# Update PC's posotion if he dies in his own turn.
	_pc_action.set_source_position()
	_pc_action.game_over(win)
	_end_game = true
	set_process_unhandled_input(true)


func _on_SwitchScreen_screen_switched(_source: int, target: int) -> void:
	set_process_unhandled_input(target == Game_ScreenTag.MAIN)


func _is_move_input(event: InputEvent) -> bool:
	for m in Game_InputTag.MOVE_INPUT:
		if event.is_action_pressed(m):
			_direction = m
			return true
	_direction = ""
	return false


func _is_mouse_move_input(event: InputEvent) -> bool:
	var mouse_pos: Game_IntCoord
	var pc_pos: Game_IntCoord

	if not _ref_GameSetting.get_mouse_input():
		return false
	elif not _verify_input(event, Game_InputTag.MOVE_BY_MOUSE):
		return false

	mouse_pos = Game_ConvertCoord.mouse_to_coord(event)
	# print(String(mouse_pos.x) + "," + String(mouse_pos.y))
	pc_pos = Game_ConvertCoord.sprite_to_coord(_ref_DungeonBoard.get_pc())
	_direction = ""

	if mouse_pos.x == pc_pos.x:
		if mouse_pos.y < pc_pos.y:
			_direction = Game_InputTag.MOVE_UP
		elif mouse_pos.y > pc_pos.y:
			_direction = Game_InputTag.MOVE_DOWN
	elif mouse_pos.y == pc_pos.y:
		if mouse_pos.x < pc_pos.x:
			_direction = Game_InputTag.MOVE_LEFT
		elif mouse_pos.x > pc_pos.x:
			_direction = Game_InputTag.MOVE_RIGHT

	return _direction != ""


func _handle_move_input() -> void:
	# PC may move more than once in his turn, therefore we need to update his
	# position accordingly.
	_pc_action.set_source_position()
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


func _handle_wait_input() -> void:
	# PC may move to another place before waiting in his turn, therefore we need
	# to update his position accordingly.
	_pc_action.set_source_position()
	_pc_action.wait()


func _is_mouse_action(event: InputEvent, input_tag: String) -> bool:
	if not _ref_GameSetting.get_mouse_input():
		return false
	return _verify_input(event, input_tag)


func _is_mouse_force_reload(event: InputEvent) -> bool:
	var mouse_pos: Game_IntCoord

	if _is_mouse_action(event, Game_InputTag.FORCE_RELOAD_BY_MOUSE):
		mouse_pos = Game_ConvertCoord.mouse_to_coord(event)
		return (mouse_pos.x == BOTTOM_RIGHT_X) \
				and (mouse_pos.y == BOTTOM_RIGHT_Y)
	return false
