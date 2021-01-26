extends "res://library/game_progress/ProgressTemplate.gd"


var _new_StyxData := preload("res://library/npc_data/StyxData.gd").new()

var _direction_sprite_state: Dictionary
var _init_world: bool = true


func _init(parent_node: Node2D).(parent_node) -> void:
	_direction_sprite_state = {
		0: [[0, 1], _new_SpriteTypeTag.UP, _new_ObjectStateTag.UP],
		1: [[0, -1], _new_SpriteTypeTag.DOWN, _new_ObjectStateTag.DOWN],
		2: [[1, 0], _new_SpriteTypeTag.RIGHT, _new_ObjectStateTag.RIGHT],
		3: [[-1, 0], _new_SpriteTypeTag.LEFT, _new_ObjectStateTag.LEFT],
	}


func renew_world(pc_x: int, pc_y: int) -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	# NOTE: Enable _cast_light() later.
	# _cast_light(pc_x, pc_y)

	if _init_world:
		_init_world = false
	elif _ref_ObjectData.verify_state(pc, _new_ObjectStateTag.ACTIVE):
		_ref_ObjectData.set_state(pc, _new_ObjectStateTag.DEFAULT)
	else:
		return
	_change_water_flow(pc_x, pc_y)


func _change_water_flow(pc_x: int, pc_y: int) -> void:
	var flow_path: Array = []
	var select_index: int

	_shuffle_rng(pc_x, pc_y)
	_randomize_ground()

	select_index = _get_select_index()
	for _i in range(_new_StyxData.MAX_FLOW):
		flow_path.push_back(_get_flow_path(select_index))
	for i in flow_path:
		_set_flow_path(i, select_index)


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


func _shuffle_rng(x: int, y: int) -> void:
	var repeat: int = (x + y * _new_DungeonSize.MAX_X) % 10
	_ref_RandomNumber.shuffle(repeat)


func _randomize_ground() -> void:
	var ground_sprite: Sprite

	for i in range(_new_DungeonSize.MAX_X):
		for j in range(_new_DungeonSize.MAX_Y):
			ground_sprite = _ref_DungeonBoard.get_sprite(
					_new_MainGroupTag.GROUND, i, j)
			if ground_sprite == null:
				continue
			_rotate_sprite(ground_sprite, _get_select_index())


func _get_flow_path(select_index: int) -> Array:
	var x: int = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_X)
	var y: int = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y)
	var direction: Array = _get_direction(select_index)
	var flow_path: Array = [[x, y]]

	for _i in range(_new_StyxData.FLOW_LENGTH):
		x = x + direction[0]
		y = y + direction[1]
		if not _new_CoordCalculator.is_inside_dungeon(x, y):
			break
		flow_path.push_back([x, y])
	return flow_path


func _set_flow_path(flow_path: Array, select_index: int) -> void:
	var ground_sprite: Sprite

	for i in range(0, flow_path.size()):
		ground_sprite = _ref_DungeonBoard.get_sprite(
				_new_MainGroupTag.GROUND, flow_path[i][0], flow_path[i][1])
		if ground_sprite == null:
			continue
		_rotate_sprite(ground_sprite, select_index)


func _rotate_sprite(ground_sprite: Sprite, select_index: int) -> void:
	_ref_SwitchSprite.switch_sprite(
			ground_sprite, _get_sprite_tag(select_index))
	_ref_ObjectData.set_state(
			ground_sprite, _get_state_tag(select_index))


func _get_select_index() -> int:
	return _ref_RandomNumber.get_int(0, _direction_sprite_state.size())


func _get_direction(select_index: int) -> Array:
	return _direction_sprite_state[select_index][0]


func _get_sprite_tag(select_index: int) -> String:
	return _direction_sprite_state[select_index][1]


func _get_state_tag(select_index: int) -> String:
	return _direction_sprite_state[select_index][2]
