extends "res://library/game_progress/ProgressTemplate.gd"


var _new_StyxData := preload("res://library/npc_data/StyxData.gd").new()

var _direction_sprite_state: Dictionary
var _countdown: int = _new_StyxData.RENEW_MAP


func _init(parent_node: Node2D).(parent_node) -> void:
	_direction_sprite_state = {
		0: [[0, 1], _new_SpriteTypeTag.UP, _new_ObjectStateTag.UP],
		1: [[0, -1], _new_SpriteTypeTag.DOWN, _new_ObjectStateTag.DOWN],
		2: [[1, 0], _new_SpriteTypeTag.RIGHT, _new_ObjectStateTag.RIGHT],
		3: [[-1, 0], _new_SpriteTypeTag.LEFT, _new_ObjectStateTag.LEFT],
	}


func renew_world(pc_x: int, pc_y: int) -> void:
	_change_water_flow(pc_x, pc_y)
	_cast_light(pc_x, pc_y)


func _change_water_flow(pc_x: int, pc_y: int) -> void:
	var flow_path: Array = []
	var select_index: int

	if _countdown == _new_StyxData.RENEW_MAP:
		_countdown = 0
		_shuffle_rng(pc_x, pc_y)
		_randomize_ground()

		select_index = _get_select_index()
		for _i in range(_new_StyxData.MAX_FLOW):
			flow_path.push_back(_get_flow_path(select_index))
		for i in flow_path:
			_set_flow_path(i, select_index)
	_countdown += 1


func _cast_light(pc_x: int, pc_y: int) -> void:
	var ground: Sprite
	var distance: int
	var new_color: String

	for i in range(_new_DungeonSize.MAX_X):
		for j in range(_new_DungeonSize.MAX_Y):
			ground = _ref_DungeonBoard.get_sprite(
					_new_MainGroupTag.GROUND, i, j)
			if ground == null:
				continue

			distance = _new_CoordCalculator.get_range(
				i, j, pc_x, pc_y)
			if distance > _new_StyxData.PC_MAX_SIGHT:
				new_color = _new_Palette.BACKGROUND
			elif (distance > _new_StyxData.PC_SIGHT) or (distance == 0):
				new_color = _new_Palette.get_default_color(
						_new_MainGroupTag.GROUND)
			else:
				new_color = _new_Palette.SHADOW
			ground.modulate = new_color


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
