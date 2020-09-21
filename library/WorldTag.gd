const INVALID: String = "INVALID"
const DEMO: String = "demo"

const KNIGHT: String = "knight"
const DESERT: String = "desert"
const STYX: String = "styx"
const MIRROR: String = "mirror"

var _world_tag: Array = [
	KNIGHT, DESERT, STYX, MIRROR,
]

var _tag_to_name: Dictionary = {
	DEMO: "Demo",
	KNIGHT: "Knight",
	DESERT: "Desert",
	STYX: "Styx",
	MIRROR: "Mirror",
}


func get_world_name(world_tag: String) -> String:
	if _tag_to_name.has(world_tag):
		return _tag_to_name[world_tag]
	return INVALID


func get_full_world_tag() -> Array:
	return _world_tag


func is_valid_world_tag(world_tag: String) -> bool:
	return (world_tag == DEMO) or (world_tag in _world_tag)
