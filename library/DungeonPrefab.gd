class_name Game_DungeonPrefab


class PackedPrefab:
	var max_x: int setget set_max_x, get_max_x
	var max_y: int setget set_max_y, get_max_y
	var prefab: Dictionary setget set_dungeon_prefab, get_dungeon_prefab


	func _init(__prefab: Dictionary) -> void:
		prefab = __prefab
		max_x = __prefab.size()
		if __prefab.size() > 0:
			max_y = __prefab[0].size()
		else:
			max_y = 0


	func get_max_x() -> int:
		return max_x


	func set_max_x(__) -> void:
		pass


	func get_max_y() -> int:
		return max_y


	func set_max_y(__) -> void:
		pass


	func get_dungeon_prefab() -> Dictionary:
		return prefab


	func set_dungeon_prefab(__) -> void:
		pass


const RESOURCE_PATH: String = "res://resource/dungeon_prefab/"
const WALL_CHAR: String = "#"


static func get_prefab(path_to_prefab: String, horizontal_flip: bool = false,
		vertical_flip: bool = false, rotate: bool = false) -> PackedPrefab:
	var read_file: Game_FileParser = Game_FileIOHelper.read_as_line(
			path_to_prefab)
	var dungeon: Dictionary = {}
	var new_dungeon: Dictionary
	var max_x: int
	var max_y: int
	var save_char: String
	var new_x: int
	var new_y: int

	if read_file.parse_success and (read_file.output_line.size() > 0):
		max_x = read_file.output_line[0].length()
		max_y = read_file.output_line.size()

		for x in range(0, max_x):
			dungeon[x] = []
			dungeon[x].resize(max_y)
			for y in range(0, max_y):
				dungeon[x][y] = read_file.output_line[y][x]

		if horizontal_flip:
			for y in range(0, max_y):
				for x in range(0, max_x):
					if x > max_x - x - 1:
						break
					save_char = dungeon[x][y]
					dungeon[x][y] = dungeon[max_x - x - 1][y]
					dungeon[max_x - x - 1][y] = save_char
		if vertical_flip:
			for x in range(0, max_x):
				for y in range(0, max_y):
					if y > max_y - y - 1:
						break
					save_char = dungeon[x][y]
					dungeon[x][y] = dungeon[x][max_y - y - 1]
					dungeon[x][max_y - y - 1] = save_char
		# Rotate clockwise by 90 degrees.
		if rotate:
			new_dungeon = {}
			for x in range(0, max_y):
				new_dungeon[x] = []
				new_dungeon[x].resize(max_x)
			for x in range(0, max_x):
				for y in range(0, max_y):
					new_x = max_y - y - 1
					new_y = x
					new_dungeon[new_x][new_y] = dungeon[x][y]
			dungeon = new_dungeon
	return PackedPrefab.new(dungeon)
