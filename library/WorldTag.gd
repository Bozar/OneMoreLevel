const INVALID: String = "INVALID"
const DEMO: String = "demo"

const KNIGHT: String = "knight"
const DESERT: String = "desert"
const STYX: String = "styx"
const MIRROR: String = "mirror"
const BALLOON: String = "balloon"
const FROG: String = "frog"
const RAILGUN: String = "railgun"
const HOUND: String = "hound"
const NINJA: String = "ninja"

const TAG_TO_NAME: Dictionary = {
	DEMO: "Demo",
	KNIGHT: "Knight",
	DESERT: "Desert",
	STYX: "Styx",
	MIRROR: "Mirror",
	BALLOON: "Balloon",
	FROG: "Frog",
	RAILGUN: "Railgun",
	HOUND: "Hound",
	NINJA: "Ninja",
}


func get_world_name(world_tag: String) -> String:
	if TAG_TO_NAME.has(world_tag):
		return TAG_TO_NAME[world_tag]
	return INVALID


func get_full_world_tag() -> Array:
	return TAG_TO_NAME.keys()


func is_valid_world_tag(world_tag: String) -> bool:
	return TAG_TO_NAME.has(world_tag)
