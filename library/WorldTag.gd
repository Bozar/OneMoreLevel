const INVALID: String = "INVALID"
const DEMO: String = "demo"

const KNIGHT: String = "knight"
const DESERT: String = "desert"
const STYX: String = "styx"
const MIRROR: String = "mirror"
const BALLOON: String = "balloon"
const FROG: String = "frog"

var _exclude_world: Array = [DEMO]
var _tag_to_name: Dictionary = {
	DEMO: "Demo",
	KNIGHT: "Knight",
	DESERT: "Desert",
	STYX: "Styx",
	MIRROR: "Mirror",
	BALLOON: "Balloon",
	FROG: "Frog",
}


func get_world_name(world_tag: String) -> String:
	if _tag_to_name.has(world_tag):
		return _tag_to_name[world_tag]
	return INVALID


func get_full_world_tag() -> Array:
	var full_tag: Array = []

	for i in _tag_to_name.keys():
		if i in _exclude_world:
			continue
		full_tag.push_back(i)
	return full_tag


func is_valid_world_tag(world_tag: String) -> bool:
	return world_tag in _tag_to_name.keys()
