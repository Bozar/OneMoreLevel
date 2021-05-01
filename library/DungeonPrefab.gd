class_name Game_DungeonPrefab


const RESOURCE_PATH: String = "res://library/dungeon_prefab/"
const WALL: String = "#"


func get_prefab(path_to_prefab: String, horizontal_flip: bool = false,
		vertical_flip: bool = false) -> Dictionary:
	var read_this: File = File.new()
	var __ = read_this.open(path_to_prefab, File.READ)
	var prefab_dict: Dictionary = {}
	var row: int = 0

	while not read_this.eof_reached():
		prefab_dict[row] = read_this.get_line()
		row += 1
	if horizontal_flip and vertical_flip:
		print(path_to_prefab)
	return prefab_dict


# https://docs.godotengine.org/en/stable/classes/class_directory.html
func get_file_list(path_to_dir: String) -> Array:
	var dir := Directory.new()
	var __
	var file_name: String
	var file_list: Array = []

	if dir.open(path_to_dir) == OK:
		__ = dir.list_dir_begin(true, true)
		file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				file_list.push_back(path_to_dir + "/" + file_name)
			file_name = dir.get_next()
	return file_list
