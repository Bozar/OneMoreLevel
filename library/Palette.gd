# https://coolors.co/palettes/popular/grey


const BACKGROUND: String = "212529"
const DARK: String = "343a40"
const SHADOW: String = "6c757d"
const STANDARD: String = "adb5bd"
const IMPORTANT: String = "ff8552"

const DEBUG: String = "fe4a49"

var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()

var _tag_to_color: Dictionary = {
	_new_MainGroupTag.GROUND: DARK,
	_new_MainGroupTag.TRAP: SHADOW,
	_new_MainGroupTag.BUILDING: SHADOW,
	_new_MainGroupTag.ACTOR: STANDARD,
	_new_MainGroupTag.INDICATOR: STANDARD,

	_new_SubGroupTag.CRYSTAL: STANDARD,
	_new_SubGroupTag.PC_MIRROR_IMAGE: SHADOW,
}


func get_default_color(main_tag: String, sub_tag: String = "") -> String:
	if _tag_to_color.has(sub_tag):
		return _tag_to_color[sub_tag]
	elif _tag_to_color.has(main_tag):
		return _tag_to_color[main_tag]
	else:
		return DEBUG
