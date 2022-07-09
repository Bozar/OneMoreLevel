extends ScrollContainer
class_name Game_HelpVScroll


const SCROLL_LINE := 20
const SCROLL_PAGE := 300
const DUNGEON := "Dungeon"

var _ref_Palette: Game_Palette

var _help_text: Array
var _help_index: int


func _ready() -> void:
	visible = false


func slide_scroll_bar(scroll_line: bool, scroll_down: bool) -> void:
	var distance: int

	if scroll_line:
		if scroll_down:
			distance = SCROLL_LINE
		else:
			distance = -SCROLL_LINE
	else:
		if scroll_down:
			distance = SCROLL_PAGE
		else:
			distance = -SCROLL_PAGE

	scroll_vertical += distance


func scroll_to_top_or_bottom(scroll_to_bottom: bool) -> void:
	if scroll_to_bottom:
		scroll_vertical = get_v_scrollbar().max_value as int
	else:
		scroll_vertical = 0


func switch_help_text(switch_to_next: bool) -> void:
	if switch_to_next:
		_help_index += 1
	else:
		_help_index -= 1

	if _help_index < 0:
		_reset_index(false)
	elif _help_index > _help_text.size() - 1:
		_reset_index()

	get_node(DUNGEON).text = _help_text[_help_index]
	_reset_scroll_bar()


func _on_InitWorld_world_selected(new_world: String) -> void:
	_help_text = Game_InitWorldData.get_help(new_world)
	_reset_index()

	get_node(DUNGEON).modulate = _ref_Palette.get_text_color(true)
	get_node(DUNGEON).text = _help_text[_help_index]


func _on_SwitchScreen_screen_switched(_source: int, target: int) -> void:
	_reset_scroll_bar()
	_reset_index()
	visible = (target == Game_ScreenTag.HELP)
	get_node(DUNGEON).text = _help_text[_help_index]


func _reset_scroll_bar() -> void:
	scroll_vertical = 0


func _reset_index(reset_to_min: bool = true) -> void:
	if reset_to_min:
		_help_index = 0
	else:
		_help_index = _help_text.size() - 1
