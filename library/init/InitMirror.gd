extends Game_WorldTemplate


const PATH_TO_MIRROR := Game_DungeonPrefab.RESOURCE_PATH + "mirror/"
const PATH_TO_LEFT_SIDE := "left_side.txt"
const PATH_TO_WALLS := "walls/"

const CRYSTAL_CHAR := "X"
const WALL_CHAR := "#"
const MIRROR_CHAR := "+"

var _spr_Crystal := preload("res://sprite/Crystal.tscn")
var _spr_CrystalBase := preload("res://sprite/CrystalBase.tscn")
var _spr_PCMirrorImage := preload("res://sprite/PCMirrorImage.tscn")
var _spr_Phantom := preload("res://sprite/Phantom.tscn")


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	var wall_start_points := []

	_init_middle_border(wall_start_points)
	_init_wall(wall_start_points)
	_init_floor()

	_create_pc()
	_init_crystal()
	_init_phantom()

	return _blueprint


func _init_middle_border(start_points: Array) -> void:
	var left_side := Game_DungeonPrefab.get_prefab(PATH_TO_MIRROR \
			+ PATH_TO_LEFT_SIDE)
	var create_sprite: bool
	var new_sprite: PackedScene
	var sub_tag: String

	for x in range(0, left_side.max_x):
		for y in range(0, left_side.max_y):
			create_sprite = false
			match left_side.prefab[x][y]:
				CRYSTAL_CHAR:
					create_sprite = true
					new_sprite = _spr_CrystalBase
					sub_tag = Game_SubTag.CRYSTAL_BASE
				WALL_CHAR:
					create_sprite = true
					new_sprite = _spr_Wall
					sub_tag = Game_SubTag.WALL
				MIRROR_CHAR:
					start_points.push_back(Game_IntCoord.new(x, y))
			if create_sprite:
				_add_building_to_blueprint(new_sprite, sub_tag, x, y)
				_occupy_position(x, y)


func _init_wall(start_points: Array) -> void:
	var file_list: Array = Game_FileIOHelper.get_file_list(PATH_TO_MIRROR \
			+ PATH_TO_WALLS)
	var this_coord: Game_IntCoord
	var this_prefab: Game_DungeonPrefab.PackedPrefab

	# There are 6 start points but only 4 strings in `file_list`, so we need to
	# create 2 more candidates.
	Game_ArrayHelper.shuffle(file_list, _ref_RandomNumber)
	# Duplicate an existing string.
	file_list.push_back(file_list[0])
	# Add an empty string.
	file_list.push_back("")
	# Randomize element orders.
	Game_ArrayHelper.shuffle(file_list, _ref_RandomNumber)

	for i in range(0, start_points.size()):
		if file_list[i] == "":
			continue
		this_coord = start_points[i]
		this_prefab = Game_DungeonPrefab.get_prefab(file_list[i])
		for x in range(0, this_prefab.max_x):
			for y in range(0, this_prefab.max_y):
				if this_prefab.prefab[x][y] == WALL_CHAR:
					_create_mirror(x + this_coord.x, y + this_coord.y)


func _create_mirror(x: int, y: int) -> void:
	var left_coord := Game_IntCoord.new(x, y)
	var right_coord := Game_CoordCalculator.get_mirror_image_xy(x, y,
			Game_DungeonSize.CENTER_X, y)

	for i in [left_coord, right_coord]:
		_add_building_to_blueprint(_spr_Wall, Game_SubTag.WALL, i.x, i.y)
		_occupy_position(i.x, i.y)


func _create_pc() -> void:
	var pc_x: int
	var pc_y: int
	var coord: Game_IntCoord
	var neighbor: Array

	# PC can appear at anywhere that is not a building.
	while true:
		pc_x = _ref_RandomNumber.get_int(0, Game_DungeonSize.CENTER_X)
		pc_y = _ref_RandomNumber.get_int(0, Game_DungeonSize.MAX_Y)
		if not _is_occupied(pc_x, pc_y):
			break

	coord = Game_CoordCalculator.get_mirror_image_xy(pc_x, pc_y,
			Game_DungeonSize.CENTER_X, pc_y)
	neighbor = Game_CoordCalculator.get_neighbor_xy(pc_x, pc_y,
					Game_MirrorData.CRYSTAL_DISTANCE, true) \
			+ Game_CoordCalculator.get_neighbor_xy(coord.x, coord.y,
					Game_MirrorData.CRYSTAL_DISTANCE, true)

	_add_actor_to_blueprint(_spr_PC, Game_SubTag.PC, pc_x, pc_y)
	_add_actor_to_blueprint(_spr_PCMirrorImage, Game_SubTag.PC_MIRROR_IMAGE,
			coord.x, coord.y)

	for i in neighbor:
		_occupy_position(i.x, i.y)


func _init_crystal() -> void:
	var x: int
	var y: int

	# The crystal can appear at anywhere that is not a building and not too
	# close to PC.
	while true:
		x = _ref_RandomNumber.get_x_coord()
		y = _ref_RandomNumber.get_y_coord()
		if _is_occupied(x, y):
			continue
		break

	_add_trap_to_blueprint(_spr_Crystal, Game_SubTag.CRYSTAL, x, y)
	_occupy_position(x, y)


func _init_phantom() -> void:
	for _i in range(0, Game_MirrorData.MAX_PHANTOM):
		_create_phantom()


func _create_phantom() -> void:
	var grids := []
	var neighbor: Array

	for x in range(0, Game_DungeonSize.CENTER_X):
		for y in range(0, Game_DungeonSize.MAX_Y):
			if not _is_occupied(x, y):
				grids.push_back(Game_IntCoord.new(x, y))

	if grids.size() == 0:
		return
	Game_ArrayHelper.rand_picker(grids, 1, _ref_RandomNumber)

	_add_actor_to_blueprint(_spr_Phantom, Game_SubTag.PHANTOM,
			grids[0].x, grids[0].y)
	neighbor = Game_CoordCalculator.get_neighbor(grids[0],
			Game_MirrorData.PHANTOM_SIGHT, true)
	for i in neighbor:
		_occupy_position(i.x, i.y)
