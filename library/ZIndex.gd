const MAIN_GROUP_TO_Z_INDEX: Dictionary = {
	Game_MainGroupTag.INVALID: -100,
	Game_MainGroupTag.GROUND: 0,
	Game_MainGroupTag.TRAP: 1,
	Game_MainGroupTag.BUILDING: 2,
	Game_MainGroupTag.ACTOR: 3,
	Game_MainGroupTag.INDICATOR: 4,
}


func get_z_index(main_tag: String) -> int:
	if not MAIN_GROUP_TO_Z_INDEX.has(main_tag):
		main_tag = Game_MainGroupTag.INVALID
	return MAIN_GROUP_TO_Z_INDEX[main_tag]
