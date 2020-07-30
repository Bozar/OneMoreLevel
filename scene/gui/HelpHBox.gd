extends HBoxContainer
class_name Game_HelpHBox


const DUNGEON: String = "Dungeon"

var _new_Palette := preload("res://library/Palette.gd").new()
var _new_ScreenTag: = preload("res://library/ScreenTag.gd").new()
var _new_InitWorldData := preload("res://library/InitWorldData.gd").new()


func _ready() -> void:
	visible = false


func _on_InitWorld_world_selected(new_world: String) -> void:
	get_node(DUNGEON).modulate = _new_Palette.STANDARD
	get_node(DUNGEON).text = _new_InitWorldData.get_help(new_world)


func _on_SwitchScreen_screen_switched(screen_tag: String) -> void:
	visible = (screen_tag == _new_ScreenTag.HELP)
