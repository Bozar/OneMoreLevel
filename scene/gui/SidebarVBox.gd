extends VBoxContainer
class_name Game_SidebarVBox


const TURN := "Upper/Turn"
const MESSAGE := "Upper/Message"
const WORLD := "Lower/World"
const HELP := "Lower/Help"
const VERSION := "Lower/Version"
const SEED := "Lower/Seed"

var _ref_RandomNumber: Game_RandomNumber
var _ref_CountDown: Game_CountDown
var _ref_DungeonBoard: Game_DungeonBoard
var _ref_GameSetting: Game_GameSetting
var _ref_Palette: Game_Palette

var _node_to_color: Dictionary


func _on_InitWorld_world_selected(new_world: String) -> void:
	_node_to_color = {
		TURN: _ref_Palette.get_text_color(true),
		MESSAGE: _ref_Palette.get_text_color(true),
		WORLD: _ref_Palette.get_text_color(false),
		HELP: _ref_Palette.get_text_color(false),
		VERSION: _ref_Palette.get_text_color(false),
		SEED: _ref_Palette.get_text_color(false),
	}
	_set_color()

	get_node(TURN).text = _get_turn()
	get_node(MESSAGE).text = ""

	get_node(WORLD).text = Game_WorldTag.get_world_name(new_world)
	get_node(HELP).text = Game_SidebarText.HELP
	get_node(VERSION).text = _get_version()
	get_node(SEED).text = _get_seed()


func _on_Schedule_turn_started(current_sprite: Sprite) -> void:
	if not current_sprite.is_in_group(Game_SubTag.PC):
		return
	get_node(TURN).text = _get_turn()


func _on_EndGame_game_over(win: bool) -> void:
	get_node(TURN).text = _get_turn()
	if win:
		get_node(MESSAGE).text = Game_SidebarText.WIN
	else:
		get_node(MESSAGE).text = Game_SidebarText.LOSE


func _on_SwitchScreen_screen_switched(_source: int, target: int) -> void:
	visible = (target == Game_ScreenTag.MAIN)


func _set_color() -> void:
	for i in _node_to_color.keys():
		get_node(i).modulate = _node_to_color[i]


func _get_turn() -> String:
	return Game_SidebarText.TURN.format([_ref_CountDown.get_count(true)])


func _get_seed() -> String:
	var _rng_seed: String = String(_ref_RandomNumber.rng_seed)
	var _head: String = _rng_seed.substr(0, 3)
	var _body: String = _rng_seed.substr(3, 3)
	var _tail: String = _rng_seed.substr(6)

	return Game_SidebarText.SEED.format([_head, _body, _tail])


func _get_version() -> String:
	var version := Game_SidebarText.VERSION
	var check_status := [
		_ref_GameSetting.get_json_parse_error(),
		_ref_GameSetting.get_wizard_mode(),
		_ref_GameSetting.get_mouse_input(),
	]
	var postfix := Game_SidebarText.VERSION_BAR

	for i in check_status:
		postfix += Game_SidebarText.BOOL_TO_PREFIX[i]
	return version + postfix
