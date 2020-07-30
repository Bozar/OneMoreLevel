extends VBoxContainer
class_name Game_SidebarVBox


const TURN: String = "Turn"
const MESSAGE: String = "Message"
const WORLD: String = "World"
const HELP: String = "Help"
const VERSION: String = "Version"
const SEED: String = "Seed"

const CountDown := preload("res://scene/main/CountDown.gd")

var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_Palette := preload("res://library/Palette.gd").new()
var _new_WorldTag := preload("res://library/WorldTag.gd").new()
var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_SidebarText := preload("res://library/SidebarText.gd").new()
var _new_ScreenTag := preload("res://library/ScreenTag.gd").new()

var _ref_RandomNumber: Game_RandomNumber
var _ref_DangerZone: Game_DangerZone
var _ref_CountDown: CountDown

var _node_to_color: Dictionary = {
	TURN: _new_Palette.STANDARD,
	MESSAGE: _new_Palette.STANDARD,
	WORLD: _new_Palette.SHADOW,
	HELP: _new_Palette.SHADOW,
	VERSION: _new_Palette.SHADOW,
	SEED: _new_Palette.SHADOW,
}

var _pc: Sprite
var _is_wizard: bool


func _on_InitWorld_world_selected(new_world: String) -> void:
	_set_color()

	get_node(TURN).text = _get_turn()
	get_node(MESSAGE).text = ""

	get_node(WORLD).text = _new_WorldTag.get_world_name(new_world)
	get_node(HELP).text = _new_SidebarText.HELP
	get_node(VERSION).text = _get_version()
	get_node(SEED).text = _get_seed()


func _on_CreateObject_sprite_created(new_sprite: Sprite) -> void:
	if new_sprite.is_in_group(_new_SubGroupTag.PC):
		_pc = new_sprite


func _on_Schedule_turn_started(current_sprite: Sprite) -> void:
	if not current_sprite.is_in_group(_new_SubGroupTag.PC):
		return

	get_node(TURN).text = _get_turn()
	get_node(MESSAGE).text = _get_warning()


func _on_EndGame_game_is_over(win: bool) -> void:
	if win:
		get_node(MESSAGE).text = _new_SidebarText.WIN
	else:
		get_node(MESSAGE).text = _new_SidebarText.LOSE


func _on_GameSetting_setting_loaded(
		setting: Game_GameSetting.PlayerSetting) -> void:
	_is_wizard = setting.wizard_mode


func _on_SwitchScreen_screen_switched(screen_tag: String) -> void:
	visible = (screen_tag == _new_ScreenTag.MAIN)


func _set_color() -> void:
	for i in _node_to_color.keys():
		get_node(i).modulate = _node_to_color[i]


func _get_turn() -> String:
	return _new_SidebarText.TURN.format([_ref_CountDown.get_count()])


func _get_warning() -> String:
	var _pc_pos: Array = _new_ConvertCoord.vector_to_array(_pc.position)

	if _ref_DangerZone.is_in_danger(_pc_pos[0], _pc_pos[1]):
		return _new_SidebarText.DANGER
	return  ""


func _get_seed() -> String:
	var _rng_seed: String = String(_ref_RandomNumber.rng_seed)
	var _head: String = _rng_seed.substr(0, 3)
	var _body: String = _rng_seed.substr(3, 3)
	var _tail: String = _rng_seed.substr(6)

	return _new_SidebarText.SEED.format([_head, _body, _tail])


func _get_version() -> String:
	if _is_wizard:
		return _new_SidebarText.VERSION.format([_new_SidebarText.WIZARD])
	return _new_SidebarText.VERSION.format([""])
