class_name Game_DungeonPrefab


class PackedPrefab:
	var max_x: int setget set_max_x, get_max_x
	var max_y: int setget set_max_y, get_max_y
	var prefab: Dictionary setget set_dungeon_prefab, get_dungeon_prefab


	func _init(_prefab: Dictionary, _max_x: int, _max_y: int) -> void:
		prefab = _prefab
		max_x = _max_x
		max_y = _max_y


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


class MatrixSize:
	var max_row: int setget set_max_row, get_max_row
	var max_column: int setget set_max_column, get_max_column


	func _init(_max_row: int, _max_column: int) -> void:
		max_row = _max_row
		max_column = _max_column


	func get_max_row() -> int:
		return max_row


	func set_max_row(__) -> void:
		pass


	func get_max_column() -> int:
		return max_column


	func set_max_column(__) -> void:
		pass


const RESOURCE_PATH := "res://resource/dungeon_prefab/"
const DICT_VALUE_WARNING := "Dict value is neither a string or an array."
const WALL_CHAR := "#"
const FLOOR_CHAR := "."

const DO_NOT_EDIT := 0
const HORIZONTAL_FLIP := 1
const VERTICAL_FLIP := 2
const ROTATE_RIGHT := 3


# The argument `edit` accepts an array of constant integers: HORIZONTAL_FLIP,
# VERTICAL_FLIP, ROTATE_RIGHT.
static func get_prefab(path_to_prefab: String, edit := []) -> PackedPrefab:
	var read_file: Game_FileParser = Game_FileIOHelper.read_as_line(
			path_to_prefab)
	var dungeon := {}
	var matrix_size: MatrixSize
	var max_x: int
	var max_y: int
	var refresh_size := false

	if read_file.parse_success and (read_file.output_line.size() > 0):
		matrix_size = _get_matrix_size(read_file.output_line)
		max_x = matrix_size.max_column
		max_y = matrix_size.max_row

		# The file is read by lines. Therefore in order to get a grid [x, y], we
		# need to call output_line[y][x], which is inconvenient. Swap [x, y] and
		# [y, x] to make life easier.
		#
		#   column
		# ----------> x
		# |
		# | row
		# |
		# v y
		for x in range(0, max_x):
			dungeon[x] = []
			dungeon[x].resize(max_y)
			for y in range(0, max_y):
				dungeon[x][y] = read_file.output_line[y][x]

		for i in edit:
			match i:
				HORIZONTAL_FLIP:
					dungeon = _horizontal_flip(dungeon, max_x, max_y)
				VERTICAL_FLIP:
					dungeon = _vertical_flip(dungeon, max_x, max_y)
				ROTATE_RIGHT:
					dungeon = _rotate_right(dungeon, max_x, max_y)
					refresh_size = true
			# Update max_x and max_y after the prefab is rotated.
			if refresh_size:
				matrix_size = _get_matrix_size(dungeon)
				max_x = matrix_size.max_row
				max_y = matrix_size.max_column
				refresh_size = false
	return PackedPrefab.new(dungeon, max_x, max_y)


static func _horizontal_flip(dungeon: Dictionary, max_x: int, max_y: int) \
		-> Dictionary:
	var mirror: int

	for y in range(0, max_y):
		for x in range(0, max_x):
			mirror = max_x - x - 1
			if x > mirror:
				break
			_swap_matrix_value(dungeon, x, y, mirror, y)
	return dungeon


static func _vertical_flip(dungeon: Dictionary, max_x: int, max_y: int) \
		-> Dictionary:
	var mirror: int

	for x in range(0, max_x):
		for y in range(0, max_y):
			mirror = max_y - y - 1
			if y > mirror:
				break
			_swap_matrix_value(dungeon, x, y, x, mirror)
	return dungeon


static func _rotate_right(dungeon: Dictionary, max_x: int, max_y: int) \
		-> Dictionary:
	var new_dungeon := {}
	var new_x: int
	var new_y: int

	for x in range(0, max_y):
		new_dungeon[x] = []
		new_dungeon[x].resize(max_x)
	for x in range(0, max_x):
		for y in range(0, max_y):
			new_x = max_y - y - 1
			new_y = x
			new_dungeon[new_x][new_y] = dungeon[x][y]
	return new_dungeon


static func _get_matrix_size(matrix_dict: Dictionary) -> MatrixSize:
	var max_row := matrix_dict.size()
	var max_column := 0

	if max_row > 0:
		match typeof(matrix_dict[0]):
			TYPE_STRING:
				max_column = matrix_dict[0].length()
			TYPE_ARRAY:
				max_column = matrix_dict[0].size()
			_:
				push_warning(DICT_VALUE_WARNING)
	return MatrixSize.new(max_row, max_column)


static func _swap_matrix_value(matrix: Dictionary, x: int, y: int,
		that_x: int, that_y: int) -> void:
	var save_char: String = matrix[x][y]

	matrix[x][y] = matrix[that_x][that_y]
	matrix[that_x][that_y] = save_char
