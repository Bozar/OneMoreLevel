extends Game_WorldTemplate


const PATH_TO_FACTORY := Game_DungeonPrefab.RESOURCE_PATH + "factory/"
const PATH_TO_START_POINT := "start_point/"
const PATH_TO_BIG_ROOM := "big_room/"
const PATH_TO_SMALL_ROOM := "small_room/"

const DOOR_CHAR := "+"
const INNER_DOOR_CHAR := "="
const CLOCK_CHAR := "-"

const EDIT_PREFAB_ARG := [
	Game_DungeonPrefab.HORIZONTAL_FLIP,
	Game_DungeonPrefab.VERTICAL_FLIP,
	Game_DungeonPrefab.ROTATE_RIGHT,
	Game_DungeonPrefab.DO_NOT_EDIT,
	Game_DungeonPrefab.DO_NOT_EDIT,
	Game_DungeonPrefab.DO_NOT_EDIT,
]
const MAX_EDIT_ARG := 3

const MAX_RETRY_CREATE_ROOM := 100
const MAX_RETRY_BUILD_FROM_PREFAB := 9

const MAX_START_POINT := 1
const MAX_BIG_ROOM := 3
const MAX_SMALL_ROOM := 12
# Define x coordinate for the first big room.
# [min_x (inclusive), max_x (exclusive)]
const FIRST_BIG_ROOM := [
	# 0: Contact with the left dungeon edge.
	# 5: There are 4 grids on the left side of the first big room, which leaves
	# space for a 3x3 small room.
	[0, 5],
	# All big rooms are 7x7.
	# -11: Leave space for a 3x3 room on the right side.
	# -6: Contact with the right dungeon edge.
	[Game_DungeonSize.MAX_X - 11, Game_DungeonSize.MAX_X - 6],
]

var _spr_Door := preload("res://sprite/Door.tscn")
var _spr_FactoryClock := preload("res://sprite/FactoryClock.tscn")
var _spr_Counter := preload("res://sprite/Counter.tscn")

var _pc_x: int
var _pc_y: int


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_create_room(PATH_TO_BIG_ROOM, MAX_BIG_ROOM)
	_create_start_point()
	_create_room(PATH_TO_SMALL_ROOM, MAX_SMALL_ROOM)
	_init_floor()
	_init_pc(0, _pc_x, _pc_y, _spr_Counter)

	return _blueprint


func _create_start_point() -> void:
	var file_list: Array = Game_FileIOHelper.get_file_list(PATH_TO_FACTORY
			+ PATH_TO_START_POINT)
	var packed_prefab: Game_DungeonPrefab.PackedPrefab
	var build_result: Array

	Game_ArrayHelper.rand_picker(file_list, MAX_START_POINT, _ref_RandomNumber)
	packed_prefab = _edit_prefab(file_list[0])
	while true:
		build_result = _build_from_prefab(packed_prefab)
		if build_result[0]:
			# PC is in the center of the room.
			_pc_x = build_result[1] + 1
			_pc_y = build_result[2] + 1
			break


func _create_room(path_to_prefab: String, max_room: int) -> void:
	var file_list: Array = Game_FileIOHelper.get_file_list(PATH_TO_FACTORY
			+ path_to_prefab)
	var file_index := 0
	var packed_prefab: Game_DungeonPrefab.PackedPrefab
	var build_result: Array
	var first_index: int
	var first_x: int
	var count_room := 0

	Game_ArrayHelper.shuffle(file_list, _ref_RandomNumber)
	for i in range(0, MAX_RETRY_CREATE_ROOM):
		if file_index > file_list.size() - 1:
			Game_ArrayHelper.shuffle(file_list, _ref_RandomNumber)
			file_index = 0
		packed_prefab = _edit_prefab(file_list[file_index])
		file_index += 1

		# Put the first big room close to the left or right dungeon edge, so
		# that it is more likely to generate another big room.
		if (i == 0) and (path_to_prefab == PATH_TO_BIG_ROOM):
			first_index = _ref_RandomNumber.get_int(0, FIRST_BIG_ROOM.size())
			first_x = _ref_RandomNumber.get_int(FIRST_BIG_ROOM[first_index][0],
					FIRST_BIG_ROOM[first_index][1])
			# NOTE: If I call shuffle() on a constant array, the same rng seed
			# may output inconsistent values. I don't know why but the code
			# below does not work.
			#
			# Game_ArrayHelper.shuffle(FIRST_BIG_ROOM, _ref_RandomNumber)
			# first_x = _ref_RandomNumber.get_int(FIRST_BIG_ROOM[0][0],
			# 		FIRST_BIG_ROOM[0][1])
			build_result = _build_from_prefab(packed_prefab, first_x)
		else:
			build_result = _build_from_prefab(packed_prefab)
		if build_result[0]:
			count_room += 1
		if count_room >= max_room:
			break


func _edit_prefab(path_to_prefab: String) -> Game_DungeonPrefab.PackedPrefab:
	var edit_arg := EDIT_PREFAB_ARG.duplicate(true)
	Game_ArrayHelper.rand_picker(edit_arg, MAX_EDIT_ARG, _ref_RandomNumber)
	return Game_DungeonPrefab.get_prefab(path_to_prefab, edit_arg)


func _build_from_prefab(packed_prefab: Game_DungeonPrefab.PackedPrefab,
		start_x: int = INVALID_COORD, start_y: int = INVALID_COORD,
		wall := [], door := [], inner_door := [], clock := [], retry := 0) \
		-> Array:
	var is_outside: bool
	var is_occupied: bool
	var is_invalid_x: bool
	var is_invalid_y: bool
	var blocked_door := 0
	var tmp_x: int
	var tmp_y: int

	if retry > MAX_RETRY_BUILD_FROM_PREFAB:
		return [false]

	if start_x == INVALID_COORD:
		start_x = _get_coord(packed_prefab, true)
	if start_y == INVALID_COORD:
		start_y = _get_coord(packed_prefab, false)

	# Expand packed_prefab by 1 grid in four directions. Make sure that:
	# 1. There are no occupied grids inside the packed_prefab.
	# 2. The packed_prefab is at least 1 grid away from an occupied grid.
	# 3. The packed_prefab can contact with a dungeon edge.
	for x in range(start_x - 1, start_x + packed_prefab.max_x + 1):
		for y in range(start_y - 1, start_y + packed_prefab.max_y + 1):
			is_outside = not Game_CoordCalculator.is_inside_dungeon(x, y)
			is_occupied = (not is_outside) and _is_occupied(x, y)
			is_invalid_x = is_outside and Game_CoordCalculator.is_in_between(
					x, start_x - 1, start_x + packed_prefab.max_x)
			is_invalid_y = is_outside and Game_CoordCalculator.is_in_between(
					y, start_y - 1, start_y + packed_prefab.max_y)

			if is_occupied or (is_invalid_x and is_invalid_y):
				tmp_x = _get_coord(packed_prefab, true)
				tmp_y = _get_coord(packed_prefab, false)
				return _build_from_prefab(packed_prefab, tmp_x, tmp_y,
						wall, door, inner_door, clock, retry + 1)

	# Parse packed_prefab.prefab, which is a dictionary, only once.
	if wall.size() == 0:
		for x in range(0, packed_prefab.max_x):
			for y in range(0, packed_prefab.max_y):
				match packed_prefab.prefab[x][y]:
					Game_DungeonPrefab.WALL_CHAR:
						wall.push_back([x, y])
					DOOR_CHAR:
						door.push_back([x, y])
					INNER_DOOR_CHAR:
						inner_door.push_back([x, y])
					CLOCK_CHAR:
						clock.push_back([x, y])

	# There must be a least one door that is not blocked by a dungeon edge.
	# This does not apply to a wall: `# + #`.
	if (packed_prefab.max_x > 1) and (packed_prefab.max_y > 1):
		for i in door:
			tmp_x = i[0] + start_x
			tmp_y = i[1] + start_y
			if _is_on_border(tmp_x, true) or _is_on_border(tmp_y, false):
				blocked_door += 1
		if blocked_door == door.size():
			tmp_x = _get_coord(packed_prefab, true)
			tmp_y = _get_coord(packed_prefab, false)
			return _build_from_prefab(packed_prefab, tmp_x, tmp_y,
					wall, door, inner_door, clock, retry + 1)

	# wall = [[x_0, y_0], [x_1, y_1], ...]
	for i in [
		[wall, _spr_Wall, Game_SubTag.WALL],
		[door, _spr_Door, Game_SubTag.DOOR],
		[inner_door, _spr_Door, Game_SubTag.DOOR],
		[clock, _spr_FactoryClock, Game_SubTag.ARROW],
	]:
		# j = [x, y]
		for j in i[0]:
			tmp_x = j[0] + start_x
			tmp_y = j[1] + start_y
			_build_building(tmp_x, tmp_y, i[1], i[2])
	return [true, start_x, start_y]


func _build_building(x: int, y: int, new_sprite: PackedScene, sub_tag: String) \
		-> void:
	_occupy_position(x, y)
	_add_to_blueprint(new_sprite, Game_MainTag.BUILDING, sub_tag, x, y)


func _get_coord(packed_prefab: Game_DungeonPrefab.PackedPrefab,
		is_x: bool) -> int:
	var max_coord: int = Game_DungeonSize.MAX_X - packed_prefab.max_x if is_x \
			else Game_DungeonSize.MAX_Y - packed_prefab.max_y

	return _ref_RandomNumber.get_int(0, max_coord)


func _is_on_border(coord: int, is_x: int) -> bool:
	if coord == 0:
		return true
	elif is_x:
		return coord == Game_DungeonSize.MAX_X - 1
	return coord == Game_DungeonSize.MAX_Y - 1
