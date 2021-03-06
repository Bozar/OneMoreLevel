extends "res://library/init/WorldTemplate.gd"


var _spr_PCFrog := preload("res://sprite/PCFrog.tscn")
var _spr_Frog := preload("res://sprite/Frog.tscn")
var _spr_Counter := preload("res://sprite/Counter.tscn")

var _new_FrogData  := preload("res://library/npc_data/FrogData.gd").new()


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_init_swamp()
	_init_pc(_new_FrogData.MIN_DISTANCE, INVALID_COORD, INVALID_COORD,
			_spr_PCFrog)
	_init_actor(0, INVALID_COORD, INVALID_COORD,
			_new_FrogData.MAX_FROG, _spr_Frog, _new_SubGroupTag.FROG)

	return _blueprint


func _init_swamp() -> void:
	var counter: int = 0

	while counter < _new_FrogData.MAX_LAND:
		counter += _init_path()

	for i in range(_new_DungeonSize.MAX_X):
		for j in range(_new_DungeonSize.MAX_Y):
			if (i == _new_DungeonSize.MAX_X - 1) \
					and (j == _new_DungeonSize.MAX_Y - 1):
				_add_to_blueprint(_spr_Counter, _new_MainGroupTag.GROUND,
						_new_SubGroupTag.COUNTER, i, j)
			elif _is_occupied(i, j):
				_add_to_blueprint(_spr_Wall, _new_MainGroupTag.GROUND,
						_new_SubGroupTag.LAND, i, j)
			else:
				_add_to_blueprint(_spr_Floor, _new_MainGroupTag.GROUND,
						_new_SubGroupTag.SWAMP, i, j)


func _init_path() -> int:
	var current_length: int = 0
	var x: int
	var y: int
	var neighbor: Array
	var counter: int

	while true:
		x = _ref_RandomNumber.get_x_coord()
		y = _ref_RandomNumber.get_y_coord()
		if not _is_occupied(x, y):
			break

	for _i in range(_new_FrogData.PATH_LENGTH):
		_occupy_position(x, y)
		current_length += 1

		neighbor = _new_CoordCalculator.get_neighbor(x, y, 1)
		counter = 0
		for j in range(neighbor.size()):
			if _is_occupied(neighbor[j][0], neighbor[j][1]):
				continue
			neighbor[counter] = neighbor[j]
			counter += 1
		neighbor.resize(counter)
		if neighbor.size() < 1:
			return current_length

		counter = _ref_RandomNumber.get_int(0, neighbor.size())
		x = neighbor[counter][0]
		y = neighbor[counter][1]

	return current_length
