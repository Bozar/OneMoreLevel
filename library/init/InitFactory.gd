extends Game_WorldTemplate


const PATH_TO_FACTORY := Game_DungeonPrefab.RESOURCE_PATH + "factory/"
const PATH_TO_START_POINT := "start_point/"
const PATH_TO_BIG_ROOM := "big_room/"
const PATH_TO_SMALL_ROOM := "small_room/"

const DOOR_CHAR := "+"
const CLOCK_CHAR := "-"
const INNER_DOOR_CHAR := "="

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

const MARKER_TREASURE:= 2
const MARKER_RARE_TREASURE := 3
const GAP_TREASURE := 2
const GAP_RARE_TREASURE := 10

var _spr_Door := preload("res://sprite/Door.tscn")
var _spr_FactoryClock := preload("res://sprite/FactoryClock.tscn")
var _spr_Counter := preload("res://sprite/Counter.tscn")
var _spr_FloorFactory := preload("res://sprite/FloorFactory.tscn")
var _spr_Treasure := preload("res://sprite/Treasure.tscn")
var _spr_RareTreasure := preload("res://sprite/RareTreasure.tscn")


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	var pos := []
	var pc := []
	var __

	_create_room(PATH_TO_BIG_ROOM, MAX_BIG_ROOM, pos)
	pc = _create_start_point(pos)
	_create_room(PATH_TO_SMALL_ROOM, MAX_SMALL_ROOM, pos)
	_init_floor()

	# Floors in a room are marked as occupied so as not to be replaced by
	# regular floors. Now we need to unmask them in order to place actors.
	for i in pos:
		_reverse_occupy(i[0], i[1])
	_init_pc(0, pc[0], pc[1], _spr_Counter)

	# The first rare treasure should be far away from PC. Others can be close to
	# PC, but not too close to each other.
	pos.resize(0)
	for i in range(0, Game_FactoryData.MAX_RARE_TREASURE):
		pos.push_back(_create_treasure(Game_SubTag.RARE_TREASURE, i == 0,
				pc[0], pc[1]))
	# Common treasure can be close to rare treasure.
	_reset_rare_treasure_gap(pos)
	for _i in range(0, Game_FactoryData.MAX_TREASURE):
		__ = _create_treasure(Game_SubTag.TREASURE, false, pc[0], pc[1])

	return _blueprint


func _create_start_point(inner_floor: Array) -> Array:
	var file_list: Array = Game_FileIOHelper.get_file_list(PATH_TO_FACTORY
			+ PATH_TO_START_POINT)
	var packed_prefab: Game_DungeonPrefab.PackedPrefab
	var build_result: Array

	Game_ArrayHelper.rand_picker(file_list, MAX_START_POINT, _ref_RandomNumber)
	packed_prefab = _edit_prefab(file_list[0])
	while true:
		build_result = _build_from_prefab(packed_prefab, inner_floor)
		if build_result[0]:
			break
	# PC is in the center of the room.
	return ([build_result[1] + 1, build_result[2] + 1])


func _create_room(path_to_prefab: String, max_room: int, inner_floor: Array) \
		-> void:
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
			build_result = _build_from_prefab(packed_prefab, inner_floor,
					first_x)
		else:
			build_result = _build_from_prefab(packed_prefab, inner_floor)
		if build_result[0]:
			count_room += 1
			# Debug output.
			if path_to_prefab == PATH_TO_BIG_ROOM:
				print(file_list[file_index - 1])
		if count_room >= max_room:
			break
	# Debug output.
	# print(count_room)


func _edit_prefab(path_to_prefab: String) -> Game_DungeonPrefab.PackedPrefab:
	var edit_arg := EDIT_PREFAB_ARG.duplicate(true)
	Game_ArrayHelper.rand_picker(edit_arg, MAX_EDIT_ARG, _ref_RandomNumber)
	return Game_DungeonPrefab.get_prefab(path_to_prefab, edit_arg)


func _build_from_prefab(packed_prefab: Game_DungeonPrefab.PackedPrefab,
		inner_floor: Array, start_x: int = INVALID_COORD,
		start_y: int = INVALID_COORD, parsed := {}, retry := 0) -> Array:
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
				return _build_from_prefab(packed_prefab, inner_floor,
						tmp_x, tmp_y, parsed, retry + 1)

	# Parse packed_prefab.parsed, which is a dictionary, only once.
	if parsed.size() == 0:
		parsed[Game_DungeonPrefab.WALL_CHAR] = []
		parsed[DOOR_CHAR] = []
		parsed[INNER_DOOR_CHAR] = []
		parsed[CLOCK_CHAR] = []
		parsed[Game_DungeonPrefab.FLOOR_CHAR] = []

		for x in range(0, packed_prefab.max_x):
			for y in range(0, packed_prefab.max_y):
				match packed_prefab.prefab[x][y]:
					Game_DungeonPrefab.WALL_CHAR:
						parsed[Game_DungeonPrefab.WALL_CHAR].push_back([x, y])
					DOOR_CHAR:
						parsed[DOOR_CHAR].push_back([x, y])
					INNER_DOOR_CHAR:
						parsed[INNER_DOOR_CHAR].push_back([x, y])
					CLOCK_CHAR:
						parsed[CLOCK_CHAR].push_back([x, y])
					Game_DungeonPrefab.FLOOR_CHAR:
						parsed[Game_DungeonPrefab.FLOOR_CHAR].push_back([x, y])

	# There must be a least one door that is not blocked by a dungeon edge.
	# This does not apply to a wall: `# + #`.
	if (packed_prefab.max_x > 1) and (packed_prefab.max_y > 1):
		for i in parsed[DOOR_CHAR]:
			tmp_x = i[0] + start_x
			tmp_y = i[1] + start_y
			if _is_on_border(tmp_x, true) or _is_on_border(tmp_y, false):
				blocked_door += 1
		if blocked_door == parsed[DOOR_CHAR].size():
			tmp_x = _get_coord(packed_prefab, true)
			tmp_y = _get_coord(packed_prefab, false)
			return _build_from_prefab(packed_prefab, inner_floor, tmp_x, tmp_y,
					parsed, retry + 1)

	for i in [
		[Game_DungeonPrefab.WALL_CHAR, _spr_Wall, Game_SubTag.WALL],
		[DOOR_CHAR, _spr_Door, Game_SubTag.DOOR],
		[INNER_DOOR_CHAR, _spr_Door, Game_SubTag.DOOR],
		[CLOCK_CHAR, _spr_FactoryClock, Game_SubTag.ARROW],
	]:
		# j = [x, y]
		for j in parsed[i[0]]:
			tmp_x = j[0] + start_x
			tmp_y = j[1] + start_y
			_build_building(tmp_x, tmp_y, i[1], i[2])
	for i in parsed[Game_DungeonPrefab.FLOOR_CHAR]:
		tmp_x = i[0] + start_x
		tmp_y = i[1] + start_y
		_add_to_blueprint(_spr_FloorFactory, Game_MainTag.GROUND,
				Game_SubTag.FLOOR, tmp_x, tmp_y)
		_occupy_position(tmp_x, tmp_y)
		inner_floor.push_back([tmp_x, tmp_y])
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


func _create_treasure(sub_tag: String, is_first_rare_treasure: bool,
		pc_x: int, pc_y: int) -> Array:
	var x: int
	var y: int
	var marker: int
	var new_sprite: PackedScene
	var gap: int
	var pc_gap: int = Game_DungeonSize.MAX_Y if is_first_rare_treasure \
			else GAP_TREASURE

	match sub_tag:
		Game_SubTag.TREASURE:
			marker = MARKER_TREASURE
			new_sprite = _spr_Treasure
			gap = GAP_TREASURE
		Game_SubTag.RARE_TREASURE:
			marker = MARKER_RARE_TREASURE
			new_sprite = _spr_RareTreasure
			gap = GAP_RARE_TREASURE
		_:
			return []

	while true:
		x = _ref_RandomNumber.get_x_coord()
		y = _ref_RandomNumber.get_y_coord()
		if Game_CoordCalculator.is_inside_range(x, y, pc_x, pc_y, pc_gap) \
				or _is_occupied(x, y) \
				or _is_terrain_marker(x, y, marker):
			continue
		break

	_add_to_blueprint(new_sprite, Game_MainTag.TRAP, sub_tag, x, y)
	for i in Game_CoordCalculator.get_neighbor(x, y, gap, true):
		if _is_occupied(i[0], i[1]):
			continue
		_set_terrain_marker(i[0], i[1], marker)
	return [x, y]


func _reset_rare_treasure_gap(coord: Array) -> void:
	for i in coord:
		for j in Game_CoordCalculator.get_neighbor(i[0], i[1], GAP_TREASURE,
				true):
			if _is_occupied(j[0], j[1]):
				continue
			_set_terrain_marker(j[0], j[1], MARKER_TREASURE)
