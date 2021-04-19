extends "res://library/init/WorldTemplate.gd"


const ROOM_SIZE: int = 4
const CORRIDOR_WIDTH: int = 1
const PICK_ROOM: int = 11
const MAX_WALL: int = 44
const MIN_X: int = 1
const MIN_Y: int = 0
const MIN_SHIFT: int = 1
const MAX_SHIFT: int = 3

var _spr_FloorHound := preload("res://sprite/FloorHound.tscn")
var _spr_PCHound := preload("res://sprite/PCHound.tscn")
var _spr_Counter := preload("res://sprite/Counter.tscn")
var _spr_Hound := preload("res://sprite/Hound.tscn")

var _new_HoundData := preload("res://library/npc_data/HoundData.gd").new()


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_init_wall()
	_init_floor(_spr_FloorHound)
	_create_pc()
	_init_actor(_new_HoundData.MIN_HOUND_GAP, INVALID_COORD, INVALID_COORD,
			_new_HoundData.MAX_HOUND, _spr_Hound, _new_SubGroupTag.HOUND)

	return _blueprint


func _init_wall() -> void:
	var counter_index: int = _ref_RandomNumber.get_int(0, MAX_WALL)
	var start_point: Array = _get_top_left_position()
	var x: int
	var y: int
	var neighbor: Array

	_new_ArrayHelper.rand_picker(start_point, PICK_ROOM, _ref_RandomNumber)
	for i in start_point:
		x = i[0] + _ref_RandomNumber.get_int(MIN_SHIFT, MAX_SHIFT)
		y = i[1] + _ref_RandomNumber.get_int(MIN_SHIFT, MAX_SHIFT)
		neighbor = _new_CoordCalculator.get_neighbor(x, y, 1)
		for j in neighbor:
			_occupy_position(j[0], j[1])
			if counter_index == 0:
				_add_to_blueprint(_spr_Counter,
						_new_MainGroupTag.BUILDING, _new_SubGroupTag.COUNTER,
						j[0], j[1])
			else:
				_add_to_blueprint(_spr_Wall,
						_new_MainGroupTag.BUILDING, _new_SubGroupTag.WALL,
						j[0], j[1])
			counter_index -= 1


func _get_top_left_position() -> Array:
	var valid_position: Array = []
	var step: int = ROOM_SIZE + CORRIDOR_WIDTH

	# By setting MIN_X to 1, it is guarantted that every grid is reachable.
	for x in range(MIN_X, _new_DungeonSize.MAX_X, step):
		if x + ROOM_SIZE < _new_DungeonSize.MAX_X:
			for y in range(MIN_Y, _new_DungeonSize.MAX_Y, step):
				if y + ROOM_SIZE < _new_DungeonSize.MAX_Y:
					valid_position.push_back([x, y])
	return valid_position


func _create_pc() -> void:
	var x: int
	var y: int
	var neighbor: Array

	while true:
		x = _ref_RandomNumber.get_x_coord()
		y = _ref_RandomNumber.get_y_coord()
		if _is_occupied(x, y):
			continue
		neighbor = _new_CoordCalculator.get_neighbor(x, y, 1)
		for i in neighbor:
			if not _is_occupied(i[0], i[1]):
				_init_pc(_new_HoundData.PC_SIGHT, x, y, _spr_PCHound)
				return
