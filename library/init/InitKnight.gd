extends "res://library/init/WorldTemplate.gd"
# Initialize a map for Silent Knight Hall (Knight).


const PATH_MARKER: int = 1
const WALL_MARKER: int = 2

const MIN_BLOCK_SIZE: int = 4
const MAX_BLOCK_SIZE: int = 5
const MAX_BLOCK_COUNT: int = 6

const MIN_PC_DISTANCE: int = 5
const MIN_NPC_DISTANCE: int = 3

const MAX_RETRY: int = 999

var _spr_Knight := preload("res://sprite/Knight.tscn")
var _spr_KnightCaptain := preload("res://sprite/KnightCaptain.tscn")
var _spr_Counter := preload("res://sprite/Counter.tscn")

var _new_KnightData := preload("res://library/npc_data/KnightData.gd").new()

var _has_counter: bool = false


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	for _i in range(MAX_RETRY):
		_init_wall()
	_fill_hole()
	_init_floor()

	_create_actor(_spr_PC, _new_SubGroupTag.PC, MIN_PC_DISTANCE)
	_create_actor(_spr_KnightCaptain, _new_SubGroupTag.KNIGHT_CAPTAIN,
			MIN_NPC_DISTANCE)
	for _i in range(_new_KnightData.MAX_KNIGHT):
		_create_actor(_spr_Knight, _new_SubGroupTag.KNIGHT, MIN_NPC_DISTANCE)

	return _blueprint


func _init_wall() -> void:
	# The start point of a wall block can be slightly out of dungeon board.
	# Because the minimum block size is greater than 1 and it will be shrinked
	# by 1 grid later.
	var x: int = _ref_RandomNumber.get_int(-MAX_BLOCK_SIZE + 2,
			_new_DungeonSize.MAX_X - 1)
	var y: int = _ref_RandomNumber.get_int(-MAX_BLOCK_SIZE + 2,
			_new_DungeonSize.MAX_Y - 1)
	var width: int = MAX_BLOCK_SIZE
	var height: int = MAX_BLOCK_SIZE
	var block: Array
	var dup_block: Array
	var new_sprite: PackedScene
	var new_sub_tag: String

	# Draw a rectangular. A 3*3 square block is too big.
	while width + height == MAX_BLOCK_SIZE * 2:
		width = _ref_RandomNumber.get_int(MIN_BLOCK_SIZE, MAX_BLOCK_SIZE + 1)
		height = _ref_RandomNumber.get_int(MIN_BLOCK_SIZE, MAX_BLOCK_SIZE + 1)
	block = _new_CoordCalculator.get_block(x, y, width, height)

	# Cannot overlap existing blocks.
	_new_ArrayHelper.filter_element(block, self, "_is_empty_space", [])
	if block.size() == 0:
		return
	dup_block = block.duplicate()
	for i in block:
		_set_terrain_marker(i[0], i[1], PATH_MARKER)

	# Shrink by 1 grid in four directions. Leave paths around the block.
	_new_ArrayHelper.filter_element(block, self, "_is_building_site",
			[x, y, width, height])

	# Reset markers to default if fail to build any walls.
	if block.size() == 0:
		for i in dup_block:
			_set_terrain_marker(i[0], i[1], DEFAULT_MARKER)
		return

	# Dig a grid when necessary to generate a more zigzagging terrain.
	if block.size() == MAX_BLOCK_COUNT:
		_new_ArrayHelper.rand_picker(block, block.size() - 1, _ref_RandomNumber)

	# Add walls to blueprint. The first wall is replaced by a counter.
	for i in block:
		if _has_counter:
			new_sprite = _spr_Wall
			new_sub_tag = _new_SubGroupTag.WALL
		else:
			new_sprite = _spr_Counter
			new_sub_tag = _new_SubGroupTag.COUNTER
			_has_counter = true
		_set_terrain_marker(i[0], i[1], WALL_MARKER)
		_add_to_blueprint(new_sprite,
				_new_MainGroupTag.BUILDING, new_sub_tag, i[0], i[1])


func _is_empty_space(coord: Array, index: int, _opt_arg: Array) -> bool:
	var x: int = coord[index][0]
	var y: int = coord[index][1]
	return _get_terrain_marker(x, y) == DEFAULT_MARKER


func _is_building_site(coord: Array, index: int, opt_arg: Array) -> bool:
	var x: int = coord[index][0]
	var y: int = coord[index][1]
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

	for x in range(_new_DungeonSize.MAX_X):
		for y in range(_new_DungeonSize.MAX_Y):
			if _get_terrain_marker(x, y) == WALL_MARKER:
				continue
			elif (x != 0) and (x != _new_DungeonSize.MAX_X - 1) \
					and (y != 0) and (y != _new_DungeonSize.MAX_Y - 1):
				continue

			neighbor = _new_CoordCalculator.get_neighbor(x, y, 1)
			fill_this = true
			for i in neighbor:
				if _get_terrain_marker(i[0], i[1]) != WALL_MARKER:
					fill_this = false
					break
			if fill_this:
				_set_terrain_marker(x, y, WALL_MARKER)
				_add_to_blueprint(_spr_Wall,
						_new_MainGroupTag.BUILDING, _new_SubGroupTag.WALL, x, y)


func _init_floor():
	for x in range(_new_DungeonSize.MAX_X):
		for y in range(_new_DungeonSize.MAX_Y):
			if _get_terrain_marker(x, y) == WALL_MARKER:
				continue
			_add_to_blueprint(_spr_Floor,
					_new_MainGroupTag.GROUND, _new_SubGroupTag.FLOOR, x, y)


func _create_actor(scene: PackedScene, sub_tag: String, distance: int) -> void:
	var x: int
	var y: int
	var neighbor: Array

	while true:
		x = _ref_RandomNumber.get_x_coord()
		y = _ref_RandomNumber.get_y_coord()
		if _get_terrain_marker(x, y) != WALL_MARKER:
			break

	neighbor = _new_CoordCalculator.get_neighbor(x, y, distance, true)
	for i in neighbor:
		_set_terrain_marker(i[0], i[1], WALL_MARKER)
	_add_to_blueprint(scene, _new_MainGroupTag.ACTOR, sub_tag, x, y)
