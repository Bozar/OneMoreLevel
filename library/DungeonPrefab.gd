class_name Game_DungeonPrefab


const RESOURCE_PATH: String = "res://library/dungeon_prefab/"
const WALL: String = "#"


func get_prefab(path_to_prefab: String, horizontal_flip: bool = false,
		vertical_flip: bool = false) -> Dictionary:
	var result: Game_FileParser = Game_FileIOHelper.read_as_line(path_to_prefab)

	if result.parse_success:
		if horizontal_flip and vertical_flip:
			print(path_to_prefab)
	return result.output_line
