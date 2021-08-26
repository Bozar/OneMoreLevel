class_name Game_ZIndex


const MAIN_TAG_TO_Z_INDEX: Dictionary = {
	Game_MainTag.INVALID: -100,
	Game_MainTag.GROUND: 0,
	Game_MainTag.TRAP: 1,
	Game_MainTag.BUILDING: 2,
	Game_MainTag.ACTOR: 3,
	Game_MainTag.INDICATOR: 4,
}


static func get_z_index(main_tag: String) -> int:
	if not MAIN_TAG_TO_Z_INDEX.has(main_tag):
		main_tag = Game_MainTag.INVALID
	return MAIN_TAG_TO_Z_INDEX[main_tag]
