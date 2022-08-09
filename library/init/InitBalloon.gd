extends Game_WorldTemplate


const BLOCK_SIZE := 3
const TO_CENTER := 1
const MAX_RETRY := 0

var _spr_PCBalloon := preload("res://sprite/PCBalloon.tscn")
var _spr_WormSpice := preload("res://sprite/WormSpice.tscn")
var _spr_Arrow := preload("res://sprite/Arrow.tscn")


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	var valid_position: Array = _get_zone_coord()
	var pc_index: int
	var x: int
	var y: int
	var sprite_position: Array

	_init_indicator()

	pc_index = _ref_RandomNumber.get_int(0, valid_position.size())
	for i in range(0, valid_position.size()):
		sprite_position = _get_position(
			valid_position[i][0],
			valid_position[i][1],
			valid_position[i][2],
			valid_position[i][3]
		)
		x = sprite_position[0]
		y = sprite_position[1]

		if i == pc_index:
			_init_pc(0, x, y, _spr_PCBalloon)
			_add_ground_to_blueprint(_spr_Floor, Game_SubTag.FLOOR, x, y)
		else:
			_init_wall_beacon(x, y)

	_init_single_wall()
	_init_floor()

	return _blueprint


func _get_zone_coord() -> Array:
	var width: int = floor(Game_DungeonSize.MAX_X / 3.0) as int
	var middle_y: int = Game_DungeonSize.CENTER_Y
	var bottom_y: int = Game_DungeonSize.MAX_Y
	var left_top: int = 1
	var right_bottom: int = 3
	var valid_position: Array = [
		[
			left_top, width - right_bottom,
			left_top, middle_y - right_bottom
		],
		[
			width + left_top, width * 2 - right_bottom,
			left_top, middle_y - right_bottom
		],
		[
			width * 2 + left_top, width * 3 - right_bottom,
			left_top, middle_y - right_bottom
		],
		[
			left_top, width - right_bottom,
			middle_y + left_top, bottom_y - right_bottom
		],
		[
			width + left_top, width * 2 - right_bottom,
			middle_y + left_top, bottom_y - right_bottom
		],
		[
			width * 2 + left_top, width * 3 - right_bottom,
			middle_y + left_top, bottom_y - right_bottom
		],
	]

	return valid_position


func _get_position(min_x: int, max_x: int, min_y: int, max_y: int) -> Array:
	var x: int
	var y: int

	# Only the top left corner is occupied by indicators. So this loop shall
	# end rather quickly.
	while true:
		x = _ref_RandomNumber.get_int(min_x, max_x)
		y = _ref_RandomNumber.get_int(min_y, max_y)
		if not _is_occupied(x, y):
			break
	return [x, y]


func _init_indicator() -> void:
	for x in range(2):
		_add_ground_to_blueprint(_spr_Arrow, Game_SubTag.ARROW, x, 0)
		_occupy_position(x, 0)
	for y in range(1, 3):
		_add_ground_to_blueprint(_spr_Arrow, Game_SubTag.ARROW, 0, y)
		_occupy_position(0, y)


func _init_wall_beacon(x: int, y: int) -> void:
	var wall: Array = [[x, y], [x + 2, y], [x + 2, y + 2], [x, y + 2]]
	var beacon: Array = [x + 1, y + 1]

	for i in wall:
		_add_building_to_blueprint(_spr_Wall, Game_SubTag.WALL, i[0], i[1])
		_occupy_position(i[0], i[1])

	_add_trap_to_blueprint(_spr_WormSpice, Game_SubTag.TREASURE,
			beacon[0], beacon[1])
	_occupy_position(beacon[0], beacon[1])


func _init_single_wall() -> void:
	var all_coords := []

	for x in range(-TO_CENTER, Game_DungeonSize.MAX_X - TO_CENTER):
		for y in range(-TO_CENTER, Game_DungeonSize.MAX_Y - TO_CENTER):
			all_coords.push_back(Game_IntCoord.new(x, y))
	Game_WorldGenerator.create_by_coord(all_coords, Game_BalloonData.MAX_WALL,
			_ref_RandomNumber, self,
			"_is_valid_wall_coord", [],
			"_create_wall_here", [],
			MAX_RETRY)


func _is_valid_wall_coord(coord: Game_IntCoord, _retry: int, _opt: Array) \
		-> bool:
	for i in range(coord.x, coord.x + BLOCK_SIZE):
		for j in range(coord.y, coord.y + BLOCK_SIZE):
			if Game_CoordCalculator.is_inside_dungeon(i, j) \
					and _is_occupied(i, j):
				return false
	return true


func _create_wall_here(coord: Game_IntCoord, _opt: Array) -> void:
	_add_building_to_blueprint(_spr_Wall, Game_SubTag.WALL,
			coord.x + TO_CENTER, coord.y + TO_CENTER)
	_occupy_position(coord.x + TO_CENTER, coord.y + TO_CENTER)
