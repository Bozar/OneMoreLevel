extends Game_WorldTemplate
# Initialize a map for Silent Knight Hall (Knight).


const PATH_MARKER: int = 1
const WALL_MARKER: int = 2

const MIN_BLOCK_SIZE: int = 4
const MAX_BLOCK_SIZE: int = 5
const MAX_BLOCK_COUNT: int = 6

const MAX_RETRY: int = 999

var _spr_Knight := preload("res://sprite/Knight.tscn")
var _spr_KnightCaptain := preload("res://sprite/KnightCaptain.tscn")
var _spr_Counter := preload("res://sprite/Counter.tscn")

var _has_counter: bool = false


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	for _i in range(MAX_RETRY):
		_init_wall()
	_fill_hole()
	_create_floor()

	_create_actor(Game_SubTag.PC)
	_create_actor(Game_SubTag.KNIGHT_CAPTAIN)
	for _i in range(Game_KnightData.MAX_KNIGHT):
		_create_actor(Game_SubTag.KNIGHT)

	return BLUEPRINT


func _init_wall() -> void:
	# The start point of a wall block can be slightly out of dungeon board.
	# Because the minimum block size is greater than 1 and it will be shrinked
	# by 1 grid later.
	var x: int = _ref_RandomNumber.get_int(-MAX_BLOCK_SIZE + 2,
			Game_DungeonSize.MAX_X - 1)
	var y: int = _ref_RandomNumber.get_int(-MAX_BLOCK_SIZE + 2,
			Game_DungeonSize.MAX_Y - 1)
	var width: int = MAX_BLOCK_SIZE
	var height: int = MAX_BLOCK_SIZE
	var block: Array
	var dup_block: Array
	var new_sprite: PackedScene
	var new_sub_tag: String

	# Draw a rectangle. A 3*3 square block is too big.
	while width + height == MAX_BLOCK_SIZE * 2:
		width = _ref_RandomNumber.get_int(MIN_BLOCK_SIZE, MAX_BLOCK_SIZE + 1)
		height = _ref_RandomNumber.get_int(MIN_BLOCK_SIZE, MAX_BLOCK_SIZE + 1)
	block = Game_CoordCalculator.get_block(x, y, width, height)

	# Cannot overlap existing blocks.
	Game_ArrayHelper.filter_element(block, self, "_is_empty_space", [])
	if block.size() == 0:
		return
	dup_block = block.duplicate()
	for i in block:
		_set_terrain_marker(i.x, i.y, PATH_MARKER)

	# Shrink by 1 grid in four directions. Leave paths around the block.
	Game_ArrayHelper.filter_element(block, self, "_is_building_site",
			[x, y, width, height])

	# Reset markers to default if fail to build any walls.
	if block.size() == 0:
		for i in dup_block:
			_set_terrain_marker(i.x, i.y, DEFAULT_MARKER)
		return

	# Dig a grid when necessary to generate a more zigzagging terrain.
	if block.size() == MAX_BLOCK_COUNT:
		Game_ArrayHelper.rand_picker(block, block.size() - 1, _ref_RandomNumber)

	# Add walls to blueprint. The first wall is replaced by a counter.
	for i in block:
		if _has_counter:
			new_sprite = _spr_Wall
			new_sub_tag = Game_SubTag.WALL
		else:
			new_sprite = _spr_Counter
			new_sub_tag = Game_SubTag.COUNTER
			_has_counter = true
		_set_terrain_marker(i.x, i.y, WALL_MARKER)
		_add_building_to_blueprint(new_sprite, new_sub_tag, i.x, i.y)


func _is_empty_space(coord: Array, index: int, _opt_arg: Array) -> bool:
	var x: int = coord[index].x
	var y: int = coord[index].y
	return _get_terrain_marker(x, y) == DEFAULT_MARKER


func _is_building_site(coord: Array, index: int, opt_arg: Array) -> bool:
	var x: int = coord[index].x
	var y: int = coord[index].y
	var start_x: int = opt_arg[0]
	var start_y: int = opt_arg[1]
	var width: int = opt_arg[2]
	var height: int = opt_arg[3]

	if (x == start_x) or (x == start_x + width - 1) \
			or (y == start_y) or (y == start_y + height - 1):
		return false
	return true


func _fill_hole() -> void:
	var neighbor: Array
	var fill_this: bool

	for x in range(Game_DungeonSize.MAX_X):
		for y in range(Game_DungeonSize.MAX_Y):
			if _get_terrain_marker(x, y) == WALL_MARKER:
				continue
			elif (x != 0) and (x != Game_DungeonSize.MAX_X - 1) \
					and (y != 0) and (y != Game_DungeonSize.MAX_Y - 1):
				continue

			neighbor = Game_CoordCalculator.get_neighbor_xy(x, y, 1)
			fill_this = true
			for i in neighbor:
				if _get_terrain_marker(i.x, i.y) != WALL_MARKER:
					fill_this = false
					break
			if fill_this:
				_set_terrain_marker(x, y, WALL_MARKER)
				_add_building_to_blueprint(_spr_Wall, Game_SubTag.WALL, x, y)


func _create_floor():
	for x in range(Game_DungeonSize.MAX_X):
		for y in range(Game_DungeonSize.MAX_Y):
			if _get_terrain_marker(x, y) == WALL_MARKER:
				continue
			_add_ground_to_blueprint(_spr_Floor, Game_SubTag.FLOOR, x, y)


func _create_actor(sub_tag: String) -> void:
	var coords := Game_DungeonSize.get_all_coords()
	var new_actor: PackedScene
	var min_distance: int

	match sub_tag:
		Game_SubTag.PC:
			new_actor = _spr_PC
			min_distance = Game_KnightData.RENDER_RANGE
		Game_SubTag.KNIGHT:
			new_actor = _spr_Knight
			min_distance = Game_KnightData.KNIGHT_GAP
		Game_SubTag.KNIGHT_CAPTAIN:
			new_actor = _spr_KnightCaptain
			min_distance = Game_KnightData.KNIGHT_GAP

	Game_WorldGenerator.create_by_coord(coords, 1, _ref_RandomNumber, self,
			"_is_valid_coord", [],
			"_create_here", [min_distance, new_actor, sub_tag])


func _is_valid_coord(coord: Game_IntCoord, _retry: int, _arg: Array) -> bool:
	return _get_terrain_marker(coord.x, coord.y) != WALL_MARKER


func _create_here(coord: Game_IntCoord, opt_arg: Array) -> void:
	var min_distance: int = opt_arg[0]
	var new_actor: PackedScene = opt_arg[1]
	var sub_tag: String = opt_arg[2]

	for i in Game_CoordCalculator.get_neighbor(coord, min_distance, true):
		_set_terrain_marker(i.x, i.y, WALL_MARKER)
	_add_actor_to_blueprint(new_actor, sub_tag, coord.x, coord.y)
