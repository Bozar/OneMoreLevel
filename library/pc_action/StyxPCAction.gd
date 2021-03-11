extends "res://library/pc_action/PCActionTemplate.gd"


const INVALID_DIRECTION: int = 0
const SHOW_FULL_MAP: bool = false
# const SHOW_FULL_MAP: bool = true

var _new_StyxData := preload("res://library/npc_data/StyxData.gd").new()

var _state_to_int: Dictionary
var _input_to_int: Dictionary
var _state_to_coord: Dictionary
var _extra_turn_counter: int = 0
var _ground_sprite: Array


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


func render_fov() -> void:
	var pos: Array
	var distance: int

	if SHOW_FULL_MAP:
		return
	if _ground_sprite.size() == 0:
		_ground_sprite = _ref_DungeonBoard.get_sprites_by_tag(
				_new_MainGroupTag.GROUND)

	for i in _ground_sprite:
		pos = _new_ConvertCoord.vector_to_array(i.position)
		distance = _new_CoordCalculator.get_range(
			pos[0], pos[1], _source_position[0], _source_position[1])
		i.visible = true

		if distance > _new_StyxData.PC_MAX_SIGHT:
			i.visible = false
		elif (distance > _new_StyxData.PC_SIGHT) or (distance == 0):
			i.modulate = _new_Palette.get_default_color(
					_new_MainGroupTag.GROUND)
		else:
			i.modulate = _new_Palette.SHADOW


func wait() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	_ref_ObjectData.set_state(pc, _new_ObjectStateTag.ACTIVE)
	_extra_turn_counter = 0
	_switch_lighthouse_color()

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
			_source_position[0], _source_position[1], x, y)

	if _pc_is_near_harbor(x, y):
		_ref_EndGame.player_win()
		end_turn = false
	else:
		_try_reduce_extra_turn()
		_switch_lighthouse_color()
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


func _try_reduce_extra_turn() -> void:
	if _extra_turn_counter < _new_StyxData.EXTRA_TURN_COUNTER:
		_extra_turn_counter += 1
	else:
		_ref_CountDown.add_count(_new_StyxData.EXTRA_TURN)
		_extra_turn_counter = 0


func _switch_lighthouse_color() -> void:
	var lighthouse: Sprite = _ref_DungeonBoard.get_sprite(
			_new_MainGroupTag.BUILDING,
			_new_DungeonSize.CENTER_X, _new_DungeonSize.CENTER_Y)

	if _extra_turn_counter == _new_StyxData.EXTRA_TURN_COUNTER:
		lighthouse.modulate = _new_Palette.DARK
	else:
		lighthouse.modulate = _new_Palette.get_default_color(
				_new_MainGroupTag.BUILDING)


func _pc_is_near_harbor(x: int, y: int) -> bool:
	var neighbor: Array = _new_CoordCalculator.get_neighbor(x, y, 1)

	for i in neighbor:
		if _ref_DungeonBoard.has_sprite_with_sub_tag(
				_new_MainGroupTag.BUILDING, _new_SubGroupTag.HARBOR,
				i[0], i[1]):
			return true
	return false
