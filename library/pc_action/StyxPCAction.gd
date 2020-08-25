extends "res://library/pc_action/PCActionTemplate.gd"


var _new_StyxData := preload("res://library/npc_data/StyxData.gd").new()

var _wave_tag_to_int: Dictionary
var _input_tag_to_int: Dictionary

var _source_direction: int
var _target_direction: int
var _drift_direction: int
var _drift_position: Array

var _countdown: int = 0


func _init(parent_node: Node2D).(parent_node) -> void:
	_wave_tag_to_int = {
		_new_SubGroupTag.WAVE_UP: 0,
		_new_SubGroupTag.WAVE_RIGHT: 1,
		_new_SubGroupTag.WAVE_DOWN: 2,
		_new_SubGroupTag.WAVE_LEFT: 3,
	}

	_input_tag_to_int = {
		_new_InputTag.MOVE_UP: 0,
		_new_InputTag.MOVE_RIGHT: 1,
		_new_InputTag.MOVE_DOWN: 2,
		_new_InputTag.MOVE_LEFT: 3,
	}


func move() -> void:
	end_turn = _try_move()
	if not end_turn:
		return

	_switch_color(_source_position, true)
	_switch_color(_target_position, false)

	_countdown += 1
	if _countdown < _new_StyxData.RENEW_COUNTDOWN:
		_ref_CountDown.add_count(1)
	else:
		_countdown = 0


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
	if _target_direction == -1:
		return false
	return (_source_direction != _target_direction) \
			and ((_source_direction + _target_direction) % 2 == 0)


func _get_sprite_direction(sprite_position: Array) -> int:
	var ground_sprite: Sprite = _ref_DungeonBoard.get_sprite(
			_new_MainGroupTag.GROUND, sprite_position[0], sprite_position[1])

	if ground_sprite == null:
		return -1

	for i in _wave_tag_to_int.keys():
		if ground_sprite.is_in_group(i):
			return _wave_tag_to_int[i]
	return -1


func _switch_color(position: Array, is_default_color: bool) -> void:
	var sprite_color: String
	var neighbor: Array
	var ground_sprite: Sprite

	if is_default_color:
		sprite_color = _new_Palette.get_default_color(_new_MainGroupTag.GROUND)
	else:
		sprite_color = _new_Palette.SHADOW

	neighbor = _new_CoordCalculator.get_neighbor(
			position[0], position[1], _new_StyxData.PC_SIGHT)
	for i in neighbor:
		ground_sprite = _ref_DungeonBoard.get_sprite(
				_new_MainGroupTag.GROUND, i[0], i[1])
		if ground_sprite == null:
			continue
		ground_sprite.modulate = sprite_color
