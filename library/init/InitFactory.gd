extends Game_WorldTemplate


const PATH_TO_PREFABS := "factory"
const DOOR_CHAR := "+"

const MAX_PREFAB_ARG := 3
const MAX_RETRY_BUILD_FROM_PREFAB := 9


var _spr_Door := preload("res://sprite/Door.tscn")


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_create_wall()
	_init_floor()
	_init_pc()

	return _blueprint


func _create_wall() -> void:
	var file_list: Array = Game_FileIOHelper.get_file_list(
			Game_DungeonPrefab.RESOURCE_PATH + PATH_TO_PREFABS)
	var packed_prefab: Game_DungeonPrefab.PackedPrefab
	var edit_prefab := [
		Game_DungeonPrefab.HORIZONTAL_FLIP,
		Game_DungeonPrefab.VERTICAL_FLIP,
		Game_DungeonPrefab.ROTATE_RIGHT,
	]
	var x: int
	var y: int

	for _i in range(edit_prefab.size()):
		edit_prefab.push_back(Game_DungeonPrefab.DO_NOT_EDIT)
	Game_ArrayHelper.rand_picker(edit_prefab, MAX_PREFAB_ARG, _ref_RandomNumber)
	packed_prefab = Game_DungeonPrefab.get_prefab(file_list[0], edit_prefab)

	x = _get_max_coord(packed_prefab, true)
	y = _get_max_coord(packed_prefab, false)
	print(_build_from_prefab(packed_prefab,
			_ref_RandomNumber.get_int(0, x), _ref_RandomNumber.get_int(0, y)))


func _build_from_prefab(packed_prefab: Game_DungeonPrefab.PackedPrefab,
		start_x: int, start_y: int, wall: Array = [], door: Array = [],
		retry: int = 0) -> bool:
	var is_outside: bool
	var is_occupied: bool
	var is_invalid_x: bool
	var is_invalid_y: bool
	var blocked_door := 0
	var tmp_x: int
	var tmp_y: int

	if retry > MAX_RETRY_BUILD_FROM_PREFAB:
		return false

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
				tmp_x = _get_max_coord(packed_prefab, true)
				tmp_y = _get_max_coord(packed_prefab, false)
				return _build_from_prefab(packed_prefab,
						_ref_RandomNumber.get_int(0, tmp_x),
						_ref_RandomNumber.get_int(0, tmp_y),
						wall, door, retry + 1)

	# Parse packed_prefab.prefab, which is a dictionary, only once.
	if wall.size() == 0:
		for x in range(0, packed_prefab.max_x):
			for y in range(0, packed_prefab.max_y):
				match packed_prefab.prefab[x][y]:
					Game_DungeonPrefab.WALL_CHAR:
						wall.push_back([x, y])
					DOOR_CHAR:
						door.push_back([x, y])

	# There must be a least one door that is not blocked by a dungeon edge.
	for i in door:
		tmp_x = i[0] + start_x
		tmp_y = i[1] + start_y
		if _is_on_border(tmp_x, true) or _is_on_border(tmp_y, false):
			blocked_door += 1
	if blocked_door == door.size():
		tmp_x = _get_max_coord(packed_prefab, true)
		tmp_y = _get_max_coord(packed_prefab, false)
		return _build_from_prefab(packed_prefab,
				_ref_RandomNumber.get_int(0, tmp_x),
				_ref_RandomNumber.get_int(0, tmp_y),
				wall, door, retry + 1)

	for i in wall:
		tmp_x = i[0] + start_x
		tmp_y = i[1] + start_y
		_build_building(tmp_x, tmp_y, _spr_Wall, Game_SubTag.WALL)
	for i in door:
		tmp_x = i[0] + start_x
		tmp_y = i[1] + start_y
		_build_building(tmp_x, tmp_y, _spr_Door, Game_SubTag.DOOR)
	return true


func _build_building(x: int, y: int, new_sprite: PackedScene, sub_tag: String) \
		-> void:
	_occupy_position(x, y)
	_add_to_blueprint(new_sprite, Game_MainTag.BUILDING, sub_tag, x, y)


func _get_max_coord(packed_prefab: Game_DungeonPrefab.PackedPrefab,
		is_x: bool) -> int:
	if is_x:
		return Game_DungeonSize.MAX_X - packed_prefab.max_x
	return  Game_DungeonSize.MAX_Y - packed_prefab.max_y


func _is_on_border(coord: int, is_x: int) -> bool:
	if coord == 0:
		return true
	elif is_x:
		return coord == Game_DungeonSize.MAX_X - 1
	return coord == Game_DungeonSize.MAX_Y - 1
