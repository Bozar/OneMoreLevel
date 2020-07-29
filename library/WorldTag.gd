const INVALID: String = "INVALID"

const DEMO: String = "demo"
const KNIGHT: String = "knight"

var _world_tag: Array = [
	DEMO, KNIGHT,
]

var _tag_to_name: Dictionary = {
	DEMO: "Demo",
	KNIGHT: "Knight",
}


func get_world_name(world_tag: String) -> String:
	if _tag_to_name.has(world_tag):
		return _tag_to_name[world_tag]
	return INVALID


func get_full_world_tag() -> Array:
	return _world_tag
