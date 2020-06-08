extends "res://library/init/WorldTemplate.gd"
# Initialize a map for Silent Knight Hall (Knight).


const Player := preload("res://sprite/PC.tscn")
const Dwarf := preload("res://sprite/Dwarf.tscn")
const Wall := preload("res://sprite/Wall.tscn")


func _init(_random: RandomNumber).(_random) -> void:
	pass


func get_blueprint() -> Array:
	_init_wall()
	_init_PC()
	# _init_dwarf()

	return _blueprint


# {0: [false, ...], 1: [false, ...], ...}
func _set_dungeon_board() -> void:
	for i in range(_new_DungeonSize.MAX_X):
		_dungeon[i] = []
		for _j in range(_new_DungeonSize.MAX_Y):
			_dungeon[i].push_back(false)


func _init_wall() -> void:
	var max_retry: int = 10000

	for _i in range(max_retry):
		_create_solid_wall()


func _create_solid_wall() -> void:
	var start_x: int = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_X)
	var start_y: int = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y)
	var max_x: int
	var max_y: int

	# The actual border length is from 2 to 3.
	var min_size: int = 4
	var max_size: int = 6
	var width: int = _ref_RandomNumber.get_int(min_size, max_size)
	var height: int = _ref_RandomNumber.get_int(min_size, max_size)

	var is_not_digged: bool = true
	var is_border: bool

	# Verify the starting point and size.
	for x in range(start_x, start_x + width):
		for y in range(start_y, start_y + height):
			if (not _new_DungeonSize.is_inside_dungeon(x, y)) \
					or _is_occupied(x, y):
				return

	# Shrink the wall block in four directions by 1 grid.
	start_x += 1
	start_y += 1
	max_x = start_x + width - 2
	max_y = start_y + height - 2

	for x in range(start_x, max_x):
		for y in range(start_y, max_y):
			# Every wall block might lose one grid.
			is_border = (x == start_x) or (x == max_x - 1) \
					or (y == start_y) or (y == max_y - 1)
			if is_not_digged and is_border \
					and (_ref_RandomNumber.get_int(0, 3) == 0):
				is_not_digged = false
				continue

			# Add wall blocks to blueprint and set dungeon board.
			_add_to_blueprint(Wall,
					_new_MainGroupName.BUILDING, _new_SubGroupName.WALL,
					x, y)
			_occupy_position(x, y)


func _init_PC() -> void:
	var position: Array = _get_PC_position()

	while _dungeon[position[0]][position[1]]:
		position = _get_PC_position()

	_add_to_blueprint(Player,
			_new_MainGroupName.ACTOR, _new_SubGroupName.PC,
			position[0], position[1])


func _get_PC_position() -> Array:
	var x: int = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_X)
	var y: int = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y)

	return [x, y]


func _init_dwarf() -> void:
	var dwarf: int = _ref_RandomNumber.get_int(3, 6)
	var x: int
	var y: int

	while dwarf > 0:
		x = _ref_RandomNumber.get_int(1, _new_DungeonSize.MAX_X - 1)
		y = _ref_RandomNumber.get_int(1, _new_DungeonSize.MAX_Y - 1)

		if _is_occupied(x, y):
			continue
		_add_to_blueprint(Dwarf,
				_new_MainGroupName.ACTOR, _new_SubGroupName.DWARF,
				x, y)
		_occupy_position(x, y)

		dwarf -= 1


func _occupy_position(x: int, y: int) -> void:
	_dungeon[x][y] = true


func _is_occupied(x: int, y: int) -> bool:
	return _dungeon[x][y]
