extends Node2D
class_name Game_Palette

const MAIN_GROUP_TAG := preload("res://library/MainGroupTag.gd")
const SUB_GROUP_TAG := preload("res://library/SubGroupTag.gd")

const BACKGROUND: String = "background"
const INDICATOR: String = "indicator"

const GROUND: String = "ground"
const TRAP: String = "trap"
const BUILDING: String = "building"
const ACTOR: String = "actor"
const GUI_TEXT: String = "text"

const DARK_GROUND: String = "dark_ground"
const DARK_TRAP: String = "dark_trap"
const DARK_BUILDING: String = "dark_building"
const DARK_ACTOR: String = "dark_actor"
const DARK_GUI_TEXT: String = "dark_text"

# https://coolors.co/f8f9fa-e9ecef-dee2e6-ced4da-adb5bd-6c757d-495057-343a40-212529
const BLACK: String = "#212529"
const GREY: String = "#6C757D"
const DARK_GREY: String = "#343A40"
const WHITE: String = "#ADB5BD"

# https://coolors.co/d8f3dc-b7e4c7-95d5b2-74c69d-52b788-40916c-2d6a4f-1b4332-081c15
const GREEN: String = "#52B788"
const DARK_GREEN: String = "#2D6A4F"

# https://coolors.co/f8b945-dc8a14-b9690b-854e19-a03401
const ORANGE: String = "#F8B945"
const DARK_ORANGE: String = "#854E19"

const DEBUG: String = "#FE4A49"

const TAG_TO_COLOR: Dictionary = {
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

const SUB_TAG_TO_COLOR: Dictionary = {
	SUB_GROUP_TAG.CRYSTAL: TRAP,
	SUB_GROUP_TAG.PC_MIRROR_IMAGE: DARK_ACTOR,
}


func _ready() -> void:
	VisualServer.set_default_clear_color(BLACK)


func get_default_color(main_tag: String, sub_tag: String = "") -> String:
	if SUB_TAG_TO_COLOR.has(sub_tag):
		return TAG_TO_COLOR[SUB_TAG_TO_COLOR[sub_tag]]
	else:
		match main_tag:
			MAIN_GROUP_TAG.GROUND:
				return TAG_TO_COLOR[GROUND]
			MAIN_GROUP_TAG.TRAP:
				return TAG_TO_COLOR[TRAP]
			MAIN_GROUP_TAG.BUILDING:
				return TAG_TO_COLOR[BUILDING]
			MAIN_GROUP_TAG.ACTOR:
				return TAG_TO_COLOR[ACTOR]
			MAIN_GROUP_TAG.INDICATOR:
				return TAG_TO_COLOR[INDICATOR]
			_:
				return DEBUG


func get_dark_color(main_tag: String, sub_tag: String = "") -> String:
	if SUB_TAG_TO_COLOR.has(sub_tag):
		return TAG_TO_COLOR[SUB_TAG_TO_COLOR[sub_tag]]
	else:
		match main_tag:
			MAIN_GROUP_TAG.GROUND:
				return TAG_TO_COLOR[DARK_GROUND]
			MAIN_GROUP_TAG.TRAP:
				return TAG_TO_COLOR[DARK_TRAP]
			MAIN_GROUP_TAG.BUILDING:
				return TAG_TO_COLOR[DARK_BUILDING]
			MAIN_GROUP_TAG.ACTOR:
				return TAG_TO_COLOR[DARK_ACTOR]
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
		return TAG_TO_COLOR[GUI_TEXT]
	return TAG_TO_COLOR[DARK_GUI_TEXT]
