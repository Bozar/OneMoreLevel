class_name Game_WorldTag
# setting.json requires a string tag.


const INVALID := "INVALID"
const DEMO := "demo"

const KNIGHT := "knight"
const DESERT := "desert"
const STYX := "styx"
const MIRROR := "mirror"
const BALLOON := "balloon"
const FROG := "frog"
const RAILGUN := "railgun"
const HOUND := "hound"
const NINJA := "ninja"
const FACTORY := "factory"
const SNOWRUNNER := "snowrunner"
const BARON := "baron"

const TAG_TO_NAME := {
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
	FACTORY: "Factory",
	SNOWRUNNER: "SnowRunner",
	BARON: "Baron",
}


static func get_world_name(world_tag: String) -> String:
	if TAG_TO_NAME.has(world_tag):
		return TAG_TO_NAME[world_tag]
	return INVALID


static func get_full_world_tag() -> Array:
	return TAG_TO_NAME.keys()


static func is_valid_world_tag(world_tag: String) -> bool:
	return TAG_TO_NAME.has(world_tag)
