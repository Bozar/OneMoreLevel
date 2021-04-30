extends Game_WorldTemplate


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
			_add_to_blueprint(_spr_Floor,
					_new_MainGroupTag.GROUND, _new_SubGroupTag.FLOOR, x, y)
		else:
			_init_wall_beacon(x, y)

	_init_single_wall(0, 0)
	_init_floor()

	return _blueprint


func _get_zone_coord() -> Array:
	var width: int = floor(_new_DungeonSize.MAX_X / 3.0) as int
	var middle_y: int = _new_DungeonSize.CENTER_Y
	var bottom_y: int = _new_DungeonSize.MAX_Y
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

	while true:
		x = _ref_RandomNumber.get_int(min_x, max_x)
		y = _ref_RandomNumber.get_int(min_y, max_y)
		if not _is_occupied(x, y):
			break
	return [x, y]


func _init_indicator() -> void:
	for x in range(2):
		_add_to_blueprint(_spr_Arrow,
				_new_MainGroupTag.GROUND, _new_SubGroupTag.ARROW, x, 0)
		_occupy_position(x, 0)
	for y in range(1, 3):
		_add_to_blueprint(_spr_Arrow,
				_new_MainGroupTag.GROUND, _new_SubGroupTag.ARROW, 0, y)
		_occupy_position(0, y)


func _init_wall_beacon(x: int, y: int) -> void:
	var wall: Array = [[x, y], [x + 2, y], [x + 2, y + 2], [x, y + 2]]
	var beacon: Array = [x + 1, y + 1]

	for i in wall:
		_add_to_blueprint(_spr_Wall,
				_new_MainGroupTag.BUILDING, _new_SubGroupTag.WALL,
				i[0], i[1])
		_occupy_position(i[0], i[1])

	_add_to_blueprint(_spr_WormSpice,
			_new_MainGroupTag.TRAP, _new_SubGroupTag.TREASURE,
			beacon[0], beacon[1])
	_occupy_position(beacon[0], beacon[1])


func _init_single_wall(retry: int, count_wall: int) -> void:
	var max_retry: int = 500
	var block_size: int = 3
	var move_to_center: int = 1
	var build_wall: bool = true
	var x: int
	var y: int

	if (count_wall > Game_BalloonData.MAX_WALL) or (retry > max_retry):
		return

	x = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_X - block_size)
	y = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y - block_size)
	for i in range(x, x + block_size):
		for j in range(y, y + block_size):
			if _is_occupied(i, j):
				build_wall = false
				break

	if build_wall:
		_add_to_blueprint(_spr_Wall,
				_new_MainGroupTag.BUILDING, _new_SubGroupTag.WALL,
				x + move_to_center, y + move_to_center)
		_occupy_position(x + move_to_center, y + move_to_center)
		count_wall += 1

	retry += 1
	_init_single_wall(retry, count_wall)
