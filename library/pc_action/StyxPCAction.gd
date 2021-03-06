extends "res://library/pc_action/PCActionTemplate.gd"


const INVALID_DIRECTION: int = 0

const STATE_TO_INT: Dictionary = {
	OBJECT_STATE_TAG.UP: 1,
	OBJECT_STATE_TAG.DOWN: -1,
	OBJECT_STATE_TAG.LEFT: 2,
	OBJECT_STATE_TAG.RIGHT: -2,
	OBJECT_STATE_TAG.DEFAULT: INVALID_DIRECTION,
}
const INPUT_TO_INT: Dictionary = {
	INPUT_TAG.MOVE_UP: 1,
	INPUT_TAG.MOVE_DOWN: -1,
	INPUT_TAG.MOVE_LEFT: 2,
	INPUT_TAG.MOVE_RIGHT: -2,
}

var _new_StyxData := preload("res://library/npc_data/StyxData.gd").new()

var _extra_turn_counter: int = 0
var _ground_sprite: Array


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


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
			_new_Palette.reset_color(i, _new_MainGroupTag.GROUND)
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
	var source_direction: int = INPUT_TO_INT[_input_direction]
	var target_direction: int = _get_ground_direction(
			_target_position[0], _target_position[1])

	if _is_opposite_direction(source_direction, target_direction):
		end_turn = false
		return

	for i in _new_ObjectStateTag.DIRECTION_TO_COORD.keys():
		x = _target_position[0]
		y = _target_position[1]
		while _new_CoordCalculator.is_inside_dungeon(x, y) \
				and (_get_ground_direction(x, y) == STATE_TO_INT[i]):
			x += _new_ObjectStateTag.DIRECTION_TO_COORD[i][0]
			y += _new_ObjectStateTag.DIRECTION_TO_COORD[i][1]
		if (x != _target_position[0]) or (y != _target_position[1]):
			x -= _new_ObjectStateTag.DIRECTION_TO_COORD[i][0]
			y -= _new_ObjectStateTag.DIRECTION_TO_COORD[i][1]
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
	return STATE_TO_INT[_ref_ObjectData.get_state(ground)]


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
		_new_Palette.reset_color(lighthouse, _new_MainGroupTag.BUILDING)


func _pc_is_near_harbor(x: int, y: int) -> bool:
	var neighbor: Array = _new_CoordCalculator.get_neighbor(x, y, 1)

	for i in neighbor:
		if _ref_DungeonBoard.has_sprite_with_sub_tag(
				_new_MainGroupTag.BUILDING, _new_SubGroupTag.HARBOR,
				i[0], i[1]):
			return true
	return false
