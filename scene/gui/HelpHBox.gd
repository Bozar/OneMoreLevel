extends HBoxContainer
class_name Game_HelpHBox


const DUNGEON: String = "Dungeon"
const GENERAL: String = "General"

var _new_Palette := preload("res://library/Palette.gd").new()
var _new_ScreenTag: = preload("res://library/ScreenTag.gd").new()
var _new_GeneralHelp := preload("res://library/help_text/GeneralHelp.gd").new()
var _new_InitWorldData := preload("res://library/InitWorldData.gd").new()

var _node_list: Array = [DUNGEON, GENERAL]


func _ready() -> void:
	visible = false


func _on_InitWorld_world_selected(new_world: String) -> void:
	_set_color()
	get_node(GENERAL).text = _new_GeneralHelp.TEXT
	get_node(DUNGEON).text = _new_InitWorldData.get_help(new_world)


func _on_SwitchScreen_screen_switched(screen_tag: String) -> void:
	visible = (screen_tag == _new_ScreenTag.HELP)


func _set_color() -> void:
	for i in _node_list:
		get_node(i).modulate = _new_Palette.STANDARD
