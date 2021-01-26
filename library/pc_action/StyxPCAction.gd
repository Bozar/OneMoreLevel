extends "res://library/pc_action/PCActionTemplate.gd"


const INVALID_DIRECTION: int = 0

var _new_StyxData := preload("res://library/npc_data/StyxData.gd").new()

var _state_to_int: Dictionary
var _input_to_int: Dictionary
var _state_to_coord: Dictionary

var _light_is_on: bool = true


func _init(parent_node: Node2D).(parent_node) -> void:
	_state_to_int = {
		_new_ObjectStateTag.UP: 1,
		_new_ObjectStateTag.DOWN: -1,
		_new_ObjectStateTag.LEFT: 2,
		_new_ObjectStateTag.RIGHT: -2,
		_new_ObjectStateTag.DEFAULT: INVALID_DIRECTION,
	}
	_input_to_int = {
		_new_InputTag.MOVE_UP: 1,
		_new_InputTag.MOVE_DOWN: -1,
		_new_InputTag.MOVE_LEFT: 2,
		_new_InputTag.MOVE_RIGHT: -2,
	}
	_state_to_coord = {
		_new_ObjectStateTag.UP: [0, -1],
		_new_ObjectStateTag.DOWN: [0, 1],
		_new_ObjectStateTag.LEFT: [-1, 0],
		_new_ObjectStateTag.RIGHT: [1, 0],
	}


func interact_with_building() -> void:
	var building: Sprite = _ref_DungeonBoard.get_sprite(
			_new_MainGroupTag.BUILDING,
			_target_position[0], _target_position[1])

	if building.is_in_group(_new_SubGroupTag.HARBOR):
		_ref_EndGame.player_win()
	elif building.is_in_group(_new_SubGroupTag.LIGHTHOUSE) and _light_is_on:
		building.modulate = _new_Palette.DARK
		_light_is_on = false

		_ref_CountDown.add_count(_new_StyxData.RESTORE_TURN)
		end_turn = true


func wait() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	_ref_ObjectData.set_state(pc, _new_ObjectStateTag.ACTIVE)
	.wait()


func move() -> void:
	var x: int
	var y: int
	var source_direction: int = _input_to_int[_input_direction]
	var target_direction: int = _get_ground_direction(
			_target_position[0], _target_position[1])

	if _is_opposite_direction(source_direction, target_direction):
		end_turn = false
		return

	for i in _state_to_coord.keys():
		x = _target_position[0]
		y = _target_position[1]
		while _new_CoordCalculator.is_inside_dungeon(x, y) \
				and (_get_ground_direction(x, y) == _state_to_int[i]):
			x += _state_to_coord[i][0]
			y += _state_to_coord[i][1]
		if (x != _target_position[0]) or (y != _target_position[1]):
			x -= _state_to_coord[i][0]
			y -= _state_to_coord[i][1]
			break

	_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR,
			_source_position, [x, y])
	end_turn = true


func _is_opposite_direction(source: int, target: int) -> bool:
	if target == INVALID_DIRECTION:
		return false
	return source + target == 0


func _get_ground_direction(x: int, y: int) -> int:
	var ground: Sprite = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.GROUND,
			x, y)

	if ground == null:
		return INVALID_DIRECTION
	return _state_to_int[_ref_ObjectData.get_state(ground)]
