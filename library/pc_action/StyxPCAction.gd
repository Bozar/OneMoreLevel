extends "res://library/pc_action/PCActionTemplate.gd"


const INVALID_DIRECTION: int = -1

var _new_StyxData := preload("res://library/npc_data/StyxData.gd").new()

var _state_tag_to_int: Dictionary
var _input_tag_to_int: Dictionary

var _source_direction: int
var _target_direction: int
var _drift_direction: int
var _drift_position: Array

var _light_is_on: bool = true


func _init(parent_node: Node2D).(parent_node) -> void:
	_state_tag_to_int = {
		_new_ObjectStateTag.UP: 0,
		_new_ObjectStateTag.RIGHT: 1,
		_new_ObjectStateTag.DOWN: 2,
		_new_ObjectStateTag.LEFT: 3,
		_new_ObjectStateTag.DEFAULT: INVALID_DIRECTION,
	}

	_input_tag_to_int = {
		_new_InputTag.MOVE_UP: 0,
		_new_InputTag.MOVE_RIGHT: 1,
		_new_InputTag.MOVE_DOWN: 2,
		_new_InputTag.MOVE_LEFT: 3,
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


func move() -> void:
	end_turn = _try_move()
	if end_turn:
		_switch_color(_source_position[0], _source_position[1], true)
		_switch_color(_target_position[0], _target_position[1], false)


func _try_move() -> bool:
	_source_direction = _input_tag_to_int[_input_direction]
	_target_direction = _get_sprite_direction(_target_position)

	_drift_position = _get_drift_position()
	_drift_direction = _get_sprite_direction(_drift_position)

	if _is_opposite():
		return false

	while (_source_direction == _target_direction) \
			and (_target_direction == _drift_direction):
		_target_position = _drift_position
		_drift_position = _get_drift_position()
		_drift_direction = _get_sprite_direction(_drift_position)

	_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR,
			_source_position, _target_position)
	return true


func _get_drift_position() -> Array:
	var x: int = _target_position[0] + _direction_to_coord[_input_direction][0]
	var y: int = _target_position[1] + _direction_to_coord[_input_direction][1]

	return [x, y]


func _is_opposite() -> bool:
	if _target_direction == INVALID_DIRECTION:
		return false
	return (_source_direction != _target_direction) \
			and ((_source_direction + _target_direction) % 2 == 0)


func _get_sprite_direction(sprite_position: Array) -> int:
	var ground_sprite: Sprite = _ref_DungeonBoard.get_sprite(
			_new_MainGroupTag.GROUND, sprite_position[0], sprite_position[1])

	if ground_sprite == null:
		return INVALID_DIRECTION
	return _state_tag_to_int[_ref_ObjectData.get_state(ground_sprite)]


func _switch_color(x: int, y: int, is_default: bool) -> void:
	var neighbor: Array = _new_CoordCalculator.get_neighbor(
			x, y, _new_StyxData.PC_SIGHT)
	var ground_sprite: Sprite

	for i in neighbor:
		ground_sprite = _ref_DungeonBoard.get_sprite(
				_new_MainGroupTag.GROUND, i[0], i[1])
		if ground_sprite == null:
			continue

		if is_default:
			ground_sprite.modulate = _new_Palette.get_default_color(
					_new_MainGroupTag.GROUND)
		else:
			ground_sprite.modulate = _new_Palette.SHADOW
