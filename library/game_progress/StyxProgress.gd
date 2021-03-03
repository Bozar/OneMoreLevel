extends "res://library/game_progress/ProgressTemplate.gd"


var _new_StyxData := preload("res://library/npc_data/StyxData.gd").new()
var _new_ArrayHelper := preload("res://library/ArrayHelper.gd").new()

var _init_world: bool = true
var _state_to_coord: Dictionary
var _state_to_sprite: Dictionary


func _init(parent_node: Node2D).(parent_node) -> void:
	_state_to_coord = {
		_new_ObjectStateTag.UP: [0, -1],
		_new_ObjectStateTag.DOWN: [0, 1],
		_new_ObjectStateTag.LEFT: [-1, 0],
		_new_ObjectStateTag.RIGHT: [1, 0],
	}
	_state_to_sprite = {
		_new_ObjectStateTag.UP: _new_SpriteTypeTag.UP,
		_new_ObjectStateTag.DOWN: _new_SpriteTypeTag.DOWN,
		_new_ObjectStateTag.LEFT: _new_SpriteTypeTag.LEFT,
		_new_ObjectStateTag.RIGHT: _new_SpriteTypeTag.RIGHT,
	}


func renew_world(pc_x: int, pc_y: int) -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var renew: bool = true

	if _init_world:
		_init_world = false
	elif _ref_ObjectData.verify_state(pc, _new_ObjectStateTag.ACTIVE):
		_ref_ObjectData.set_state(pc, _new_ObjectStateTag.DEFAULT)
	else:
		renew = false

	if renew:
		_change_water_flow()
	_cast_light(pc_x, pc_y)


func game_is_over(_win: bool) -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var pos: Array = _new_ConvertCoord.vector_to_array(pc.position)

	_cast_light(pos[0], pos[1])


func _change_water_flow() -> void:
	var ground: Array = _ref_DungeonBoard.get_sprites_by_tag(
			_new_MainGroupTag.GROUND)
	var valid_state: Array
	var direction: String
	var pos: Array
	var x: int
	var y: int
	var flow: Sprite

	_new_ArrayHelper.filter_element(ground, self, "_filter_change_flow", [])
	for i in ground:
		if not _ref_ObjectData.verify_state(i, _new_ObjectStateTag.DEFAULT):
			continue
		valid_state = _state_to_coord.keys()
		_new_ArrayHelper.rand_picker(valid_state, 1, _ref_RandomNumber)
		direction = valid_state[0]
		_rotate_sprite(i, direction)

		pos = _new_ConvertCoord.vector_to_array(i.position)
		x = pos[0]
		y = pos[1]
		for _j in range(_new_StyxData.FLOW_LENGTH):
			x += _state_to_coord[direction][0]
			y += _state_to_coord[direction][1]
			flow = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.GROUND, x, y)
			if (flow != null) and _ref_ObjectData.verify_state(flow,
					_new_ObjectStateTag.DEFAULT):
				_rotate_sprite(flow, direction)
			else:
				break


func _cast_light(pc_x: int, pc_y: int) -> void:
	var ground: Array = _ref_DungeonBoard.get_sprites_by_tag(
			_new_MainGroupTag.GROUND)
	var pos: Array
	var distance: int
	var new_color: String

	for i in ground:
		pos = _new_ConvertCoord.vector_to_array(i.position)
		distance = _new_CoordCalculator.get_range(
			pos[0], pos[1], pc_x, pc_y)
		if distance > _new_StyxData.PC_MAX_SIGHT:
			new_color = _new_Palette.BACKGROUND
		elif (distance > _new_StyxData.PC_SIGHT) or (distance == 0):
			new_color = _new_Palette.get_default_color(
					_new_MainGroupTag.GROUND)
		else:
			new_color = _new_Palette.SHADOW
		i.modulate = new_color


func _rotate_sprite(ground: Sprite, direction: String) -> void:
	_ref_ObjectData.set_state(ground, direction)
	_ref_SwitchSprite.switch_sprite(ground, _state_to_sprite[direction])


func _filter_change_flow(source: Array, index: int, _opt_arg) -> bool:
	_ref_ObjectData.set_state(source[index], _new_ObjectStateTag.DEFAULT)
	return true
