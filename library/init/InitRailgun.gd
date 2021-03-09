extends "res://library/init/WorldTemplate.gd"


const PATH_LENGTH: int = 16
const MAX_FLOOR: int = 150

var _spr_PCRailgun := preload("res://sprite/PCRailgun.tscn")
var _spr_Devil := preload("res://sprite/Devil.tscn")
var _spr_Counter := preload("res://sprite/Counter.tscn")

var _new_RailgunData := preload("res://library/npc_data/RailgunData.gd").new()


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_init_wall()
	_init_floor()
	_init_pc(_new_RailgunData.PC_FRONT_SIGHT, INVALID_COORD, INVALID_COORD,
			_spr_PCRailgun)
	_init_actor(_new_RailgunData.NPC_GAP, INVALID_COORD, INVALID_COORD,
			_new_RailgunData.MAX_NPC,
			_spr_Devil, _new_SubGroupTag.DEVIL)

	return _blueprint


func _init_wall() -> void:
	var end_point: Array = []
	var count_floor: int = 1

	_set_start_point(end_point)
	while count_floor < MAX_FLOOR:
		count_floor += _create_path(end_point)
	_add_wall_blueprint()


func _set_start_point(end_point: Array) -> void:
	var x: int
	var y: int

	while true:
		x = _ref_RandomNumber.get_int(1, _new_DungeonSize.MAX_X)
		y = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y)
		if _is_even(x):
			x -= 1
		if _is_odd(y):
			y -= 1
		if not _is_counter(x, y):
			break

	_occupy_position(x, y)
	_update_end_point(x, y, end_point)


func _create_path(end_point: Array) -> int:
	var select: int
	var x: int
	var y: int
	var multi_x: int
	var multi_y: int
	var step: int
	var counter: int = 0

	select = _ref_RandomNumber.get_int(0, end_point.size())
	if _is_odd(select):
		select -= 1
	x = end_point[select]
	y = end_point[select + 1]

	multi_x = _ref_RandomNumber.get_int(0, 2)
	multi_y = 0 if multi_x > 0 else 1
	step = _ref_RandomNumber.get_int(0, 2)
	step = 1 if step > 0 else -1

	for _i in range(PATH_LENGTH):
		x += multi_x * step
		y += multi_y * step

		if (not _new_CoordCalculator.is_inside_dungeon(x, y)) \
				or _is_occupied(x, y) or (_is_counter(x, y)):
			break
		else:
			counter += 1
			_occupy_position(x, y)
			_update_end_point(x, y, end_point)

	return counter


func _update_end_point(x: int, y: int, end_point: Array) -> void:
	if _is_odd(x) and _is_even(y):
		end_point.push_back(x)
		end_point.push_back(y)


func _is_even(number: int) -> bool:
	return number % 2 == 0


func _is_odd(number: int) -> bool:
	return number % 2 != 0


func _is_counter(x: int, y: int) -> bool:
	return (x >= _new_DungeonSize.MAX_X - _new_RailgunData.COUNTER_WIDTH) \
			and (y == _new_DungeonSize.MAX_Y - 1)


func _add_wall_blueprint() -> void:
	var new_sprite: PackedScene
	var new_sub_group: String

	for i in range(0, _new_DungeonSize.MAX_X):
		for j in range(0, _new_DungeonSize.MAX_Y):
			_reverse_occupy(i, j)
			if _is_occupied(i, j):
				if _is_counter(i, j):
					new_sprite = _spr_Counter
					new_sub_group = _new_SubGroupTag.COUNTER
				else:
					new_sprite = _spr_Wall
					new_sub_group = _new_SubGroupTag.WALL
				_add_to_blueprint(new_sprite,
						_new_MainGroupTag.BUILDING, new_sub_group, i, j)
