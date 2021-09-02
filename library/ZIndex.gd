class_name Game_ZIndex


const MAIN_TAG_TO_Z_INDEX := {
	Game_MainTag.INVALID: -100,
	Game_MainTag.GROUND: 0,
	Game_MainTag.TRAP: 1,
	Game_MainTag.BUILDING: 2,
	Game_MainTag.ACTOR: 3,
	Game_MainTag.INDICATOR: 4,
}
const LAYERED_MAIN_TAG := [
	Game_MainTag.GROUND,
	Game_MainTag.TRAP,
	Game_MainTag.BUILDING,
	Game_MainTag.ACTOR,
]


static func get_z_index(main_tag: String) -> int:
	if not MAIN_TAG_TO_Z_INDEX.has(main_tag):
		main_tag = Game_MainTag.INVALID
	return MAIN_TAG_TO_Z_INDEX[main_tag]
