const MAIN_GROUP_TAG := preload("res://library/MainGroupTag.gd")
const SUB_GROUP_TAG := preload("res://library/SubGroupTag.gd")

# https://coolors.co/palettes/popular/grey
const BACKGROUND: String = "212529"
const DARK: String = "343a40"
const SHADOW: String = "6c757d"
const STANDARD: String = "adb5bd"

const DEBUG: String = "fe4a49"

const TAG_TO_COLOR: Dictionary = {
	MAIN_GROUP_TAG.GROUND: DARK,
	MAIN_GROUP_TAG.TRAP: SHADOW,
	MAIN_GROUP_TAG.BUILDING: SHADOW,
	MAIN_GROUP_TAG.ACTOR: STANDARD,
	MAIN_GROUP_TAG.INDICATOR: STANDARD,

	SUB_GROUP_TAG.CRYSTAL: STANDARD,
	SUB_GROUP_TAG.PC_MIRROR_IMAGE: SHADOW,
}


func get_default_color(main_tag: String, sub_tag: String = "") -> String:
	if TAG_TO_COLOR.has(sub_tag):
		return TAG_TO_COLOR[sub_tag]
	elif TAG_TO_COLOR.has(main_tag):
		return TAG_TO_COLOR[main_tag]
	else:
		return DEBUG


func reset_color(set_sprite: Sprite, main_tag: String,
		sub_tag: String = "") -> void:
	var new_color: String = get_default_color(main_tag, sub_tag)
	set_sprite.modulate = new_color
