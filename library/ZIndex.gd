const MAIN_GROUP_TAG := preload("res://library/MainGroupTag.gd")

const MAIN_GROUP_TO_Z_INDEX: Dictionary = {
	MAIN_GROUP_TAG.INVALID: -100,
	MAIN_GROUP_TAG.GROUND: 0,
	MAIN_GROUP_TAG.TRAP: 1,
	MAIN_GROUP_TAG.BUILDING: 2,
	MAIN_GROUP_TAG.ACTOR: 3,
	MAIN_GROUP_TAG.INDICATOR: 4,
}


func get_z_index(main_tag: String) -> int:
	if not MAIN_GROUP_TO_Z_INDEX.has(main_tag):
		main_tag = MAIN_GROUP_TAG.INVALID
	return MAIN_GROUP_TO_Z_INDEX[main_tag]
