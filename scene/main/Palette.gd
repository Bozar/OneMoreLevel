extends Node2D
class_name Game_Palette


const BACKGROUND := "background"
const INDICATOR := "indicator"

const GROUND := "ground"
const TRAP := "trap"
const BUILDING := "building"
const ACTOR := "actor"
const GUI_TEXT := "gui_text"

const DARK_GROUND := "dark_ground"
const DARK_TRAP := "dark_trap"
const DARK_BUILDING := "dark_building"
const DARK_ACTOR := "dark_actor"
const DARK_GUI_TEXT := "dark_gui_text"

const COLOR_VALUE := "color_value"

const HTML_COLOR_REGEX := "^#{0,1}([0-9A-Fa-f]{3}){1,2}$"

# https://coolors.co/f8f9fa-e9ecef-dee2e6-ced4da-adb5bd-6c757d-495057-343a40-212529
const BLACK := "#212529"
const GREY := "#6C757D"
const DARK_GREY := "#343A40"
const WHITE := "#ADB5BD"

# https://coolors.co/d8f3dc-b7e4c7-95d5b2-74c69d-52b788-40916c-2d6a4f-1b4332-081c15
const GREEN := "#52B788"
const DARK_GREEN := "#2D6A4F"

# https://coolors.co/f8b945-dc8a14-b9690b-854e19-a03401
const ORANGE := "#F8B945"
const DARK_ORANGE := "#854E19"

const DEBUG := "#FE4A49"

const DEFAULT_TAG_TO_COLOR := {
	BACKGROUND: BLACK,
	INDICATOR: GREY,

	GROUND: GREY,
	TRAP: ORANGE,
	BUILDING: GREY,
	ACTOR: GREEN,
	GUI_TEXT: WHITE,

	DARK_GROUND: DARK_GREY,
	DARK_TRAP: DARK_ORANGE,
	DARK_BUILDING: DARK_GREY,
	DARK_ACTOR: DARK_GREEN,
	DARK_GUI_TEXT: GREY,

	# INDICATOR: GREY,
	# BACKGROUND: BLACK,

	# GROUND: GREY,
	# TRAP: GREY,
	# BUILDING: GREY,
	# ACTOR: WHITE,
	# GUI_TEXT: WHITE,

	# DARK_GROUND: DARK_GREY,
	# DARK_TRAP: DARK_GREY,
	# DARK_BUILDING: DARK_GREY,
	# DARK_ACTOR: GREY,
	# DARK_GUI_TEXT: GREY,
}

const SUB_TAG_TO_COLOR := {
	Game_SubTag.PC_MIRROR_IMAGE: DARK_ACTOR,
}

var _ref_GameSetting: Game_GameSetting

var _tag_to_color := {}


func get_default_color(main_tag: String, sub_tag: String = "") -> String:
	if SUB_TAG_TO_COLOR.has(sub_tag):
		return _tag_to_color[SUB_TAG_TO_COLOR[sub_tag]]
	else:
		match main_tag:
			Game_MainTag.GROUND:
				return _tag_to_color[GROUND]
			Game_MainTag.TRAP:
				return _tag_to_color[TRAP]
			Game_MainTag.BUILDING:
				return _tag_to_color[BUILDING]
			Game_MainTag.ACTOR:
				return _tag_to_color[ACTOR]
			Game_MainTag.INDICATOR:
				return _tag_to_color[INDICATOR]
			_:
				return DEBUG


func get_dark_color(main_tag: String, sub_tag: String = "") -> String:
	if SUB_TAG_TO_COLOR.has(sub_tag):
		return _tag_to_color[SUB_TAG_TO_COLOR[sub_tag]]
	else:
		match main_tag:
			Game_MainTag.GROUND:
				return _tag_to_color[DARK_GROUND]
			Game_MainTag.TRAP:
				return _tag_to_color[DARK_TRAP]
			Game_MainTag.BUILDING:
				return _tag_to_color[DARK_BUILDING]
			Game_MainTag.ACTOR:
				return _tag_to_color[DARK_ACTOR]
			_:
				return DEBUG


func set_default_color(set_sprite: Sprite, main_tag: String,
		sub_tag: String = "") -> void:
	var new_color: String = get_default_color(main_tag, sub_tag)
	set_sprite.modulate = new_color


func set_dark_color(set_sprite: Sprite, main_tag: String,
		sub_tag: String = "") -> void:
	var new_color: String = get_dark_color(main_tag, sub_tag)
	set_sprite.modulate = new_color


func get_text_color(is_light_color: bool) -> String:
	if is_light_color:
		return _tag_to_color[GUI_TEXT]
	return _tag_to_color[DARK_GUI_TEXT]


func _on_GameSetting_setting_loaded() -> void:
	var palette: Dictionary = _ref_GameSetting.get_palette()
	var has_color_value: bool = palette.has(COLOR_VALUE) \
			and (palette[COLOR_VALUE] is Dictionary)
	var color_regex := RegEx.new()
	var __ = color_regex.compile(HTML_COLOR_REGEX)

	for i in DEFAULT_TAG_TO_COLOR.keys():
		_tag_to_color[i] = ""
		if _dict_has_string(palette, i):
			if has_color_value \
					and _dict_has_string(palette[COLOR_VALUE], palette[i]):
				_tag_to_color[i] = palette[COLOR_VALUE][palette[i]]
			else:
				_tag_to_color[i] = palette[i]

		if color_regex.search(_tag_to_color[i]) == null:
			# print("Invalid color: " + i)
			_tag_to_color[i] =  DEFAULT_TAG_TO_COLOR[i]

	VisualServer.set_default_clear_color(_tag_to_color[BACKGROUND])


func _dict_has_string(this_dict: Dictionary, this_key: String) -> bool:
	return this_dict.has(this_key) and (this_dict[this_key] is String)
