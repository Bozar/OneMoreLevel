extends Node2D
class_name Game_Palette

const MAIN_GROUP_TAG := preload("res://library/MainGroupTag.gd")
const SUB_GROUP_TAG := preload("res://library/SubGroupTag.gd")

const GROUND: String = "ground"
const TRAP: String = "trap"
const BUILDING: String = "building"
const ACTOR: String = "actor"
const GUI_TEXT: String = "text"

const BACKGROUND: String = "background"
const DARK_GROUND: String = "ground_dark"
const DARK_TRAP: String = "trap_dark"
const DARK_BUILDING: String = "building_dark"
const DARK_ACTOR: String = "actor_dark"
const DARK_GUI_TEXT: String = "text_dark"

# https://coolors.co/palettes/popular/GREY
const BLACK: String = "212529"
const GREY: String = "6c757d"
const DARK_GREY: String = "343a40"
const WHITE: String = "adb5bd"

const DEBUG: String = "fe4a49"

const TAG_TO_COLOR: Dictionary = {
	GROUND: GREY,
	TRAP: GREY,
	BUILDING: GREY,
	ACTOR: WHITE,
	GUI_TEXT: WHITE,

	BACKGROUND: BLACK,
	DARK_GROUND: DARK_GREY,
	DARK_TRAP: DARK_GREY,
	DARK_BUILDING: DARK_GREY,
	DARK_ACTOR: GREY,
	DARK_GUI_TEXT: GREY,

	# GROUND: GREY,
	# TRAP: GREY,
	# BUILDING: GREY,
	# ACTOR: WHITE,
	# GUI_TEXT: WHITE,

	# BACKGROUND: BLACK,
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
				return TAG_TO_COLOR[DARK_GUI_TEXT]
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
