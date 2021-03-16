extends VBoxContainer
class_name Game_SidebarVBox


const TURN: String = "Upper/Turn"
const MESSAGE: String = "Upper/Message"
const WORLD: String = "Lower/World"
const HELP: String = "Lower/Help"
const VERSION: String = "Lower/Version"
const SEED: String = "Lower/Seed"

const PALETTE := preload("res://library/Palette.gd")

const NODE_TO_COLOR: Dictionary = {
	TURN: PALETTE.STANDARD,
	MESSAGE: PALETTE.STANDARD,
	WORLD: PALETTE.SHADOW,
	HELP: PALETTE.SHADOW,
	VERSION: PALETTE.SHADOW,
	SEED: PALETTE.SHADOW,
}

var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_WorldTag := preload("res://library/WorldTag.gd").new()
var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_SidebarText := preload("res://library/SidebarText.gd").new()
var _new_ScreenTag := preload("res://library/ScreenTag.gd").new()

var _ref_RandomNumber: Game_RandomNumber
var _ref_DangerZone: Game_DangerZone
var _ref_CountDown: Game_CountDown
var _ref_DungeonBoard: Game_DungeonBoard
var _ref_GameSetting: Game_GameSetting


func _on_InitWorld_world_selected(new_world: String) -> void:
	_set_color()

	get_node(TURN).text = _get_turn()
	get_node(MESSAGE).text = ""

	get_node(WORLD).text = _new_WorldTag.get_world_name(new_world)
	get_node(HELP).text = _new_SidebarText.HELP
	get_node(VERSION).text = _get_version()
	get_node(SEED).text = _get_seed()


func _on_Schedule_turn_started(current_sprite: Sprite) -> void:
	if not current_sprite.is_in_group(_new_SubGroupTag.PC):
		return
	get_node(TURN).text = _get_turn()
	get_node(MESSAGE).text = _get_warning()


func _on_EndGame_game_over(win: bool) -> void:
	get_node(TURN).text = _get_turn()
	if win:
		get_node(MESSAGE).text = _new_SidebarText.WIN
	else:
		get_node(MESSAGE).text = _new_SidebarText.LOSE


func _on_SwitchScreen_screen_switched(screen_tag: String) -> void:
	visible = (screen_tag == _new_ScreenTag.MAIN)


func _set_color() -> void:
	for i in NODE_TO_COLOR.keys():
		get_node(i).modulate = NODE_TO_COLOR[i]


func _get_turn() -> String:
	return _new_SidebarText.TURN.format([_ref_CountDown.get_count(true)])


func _get_warning() -> String:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var pc_pos: Array = _new_ConvertCoord.vector_to_array(pc.position)

	if _ref_DangerZone.is_in_danger(pc_pos[0], pc_pos[1]):
		return _new_SidebarText.DANGER
	return  ""


func _get_seed() -> String:
	var _rng_seed: String = String(_ref_RandomNumber.rng_seed)
	var _head: String = _rng_seed.substr(0, 3)
	var _body: String = _rng_seed.substr(3, 3)
	var _tail: String = _rng_seed.substr(6)

	return _new_SidebarText.SEED.format([_head, _body, _tail])


func _get_version() -> String:
	if _ref_GameSetting.get_json_parse_error():
		return _new_SidebarText.VERSION.format([_new_SidebarText.PARSE_ERROR])
	elif _ref_GameSetting.get_wizard_mode():
		return _new_SidebarText.VERSION.format([_new_SidebarText.WIZARD])
	return _new_SidebarText.VERSION.format([""])
