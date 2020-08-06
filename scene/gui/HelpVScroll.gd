extends ScrollContainer
class_name Game_HelpVScroll


const DUNGEON: String = "HelpHBox/Dungeon"

var _new_Palette := preload("res://library/Palette.gd").new()
var _new_ScreenTag: = preload("res://library/ScreenTag.gd").new()
var _new_InitWorldData := preload("res://library/InitWorldData.gd").new()

var _scroll_line: int = 60
var _scroll_page: int = 300


func _ready() -> void:
	visible = false


func slide_scroll_bar(scroll_line: bool, scroll_down: bool) -> void:
	var distance: int

	if scroll_line:
		if scroll_down:
			distance = _scroll_line
		else:
			distance = -_scroll_line
	else:
		if scroll_down:
			distance = _scroll_page
		else:
			distance = -_scroll_page

	scroll_vertical += distance


func scroll_to_top_or_bottom(scroll_to_bottom: bool) -> void:
	if scroll_to_bottom:
		scroll_vertical = get_v_scrollbar().max_value as int
	else:
		scroll_vertical = 0


func reset_scroll_bar() -> void:
	scroll_vertical = 0


func _on_InitWorld_world_selected(new_world: String) -> void:
	get_node(DUNGEON).modulate = _new_Palette.STANDARD
	get_node(DUNGEON).text = _new_InitWorldData.get_help(new_world)


func _on_SwitchScreen_screen_switched(screen_tag: String) -> void:
	visible = (screen_tag == _new_ScreenTag.HELP)
