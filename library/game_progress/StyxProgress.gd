extends "res://library/game_progress/ProgressTemplate.gd"


var _new_StyxData := preload("res://library/npc_data/StyxData.gd").new()

var _sprite_type: Array
var _object_state: Array

var _flow_direction: Array = [
	[0, 1], [0, -1], [1, 0], [-1, 0]
]
var _countdown: int = _new_StyxData.RENEW_MAP


func _init(parent_node: Node2D).(parent_node) -> void:
	_sprite_type = [
		_new_SpriteTypeTag.UP,
		_new_SpriteTypeTag.DOWN,
		_new_SpriteTypeTag.LEFT,
		_new_SpriteTypeTag.RIGHT,
	]

	_object_state = [
		_new_ObjectStateTag.UP,
		_new_ObjectStateTag.DOWN,
		_new_ObjectStateTag.LEFT,
		_new_ObjectStateTag.RIGHT,
	]


func renew_world(_pc_x: int, _pc_y: int) -> void:
	var flow_path: Array = []

	if _countdown == _new_StyxData.RENEW_MAP:
		_countdown = 0
		_randomize_ground()

		for _i in range(_new_StyxData.MAX_FLOW):
			flow_path.push_back(_get_flow_path())
		for i in flow_path:
			_rotate_sprite(i)
	_countdown += 1


func _randomize_ground() -> void:
	var select_index: int
	var river_sprite: Sprite

	for i in range(_new_DungeonSize.MAX_X):
		for j in range(_new_DungeonSize.MAX_Y):
			river_sprite = _ref_DungeonBoard.get_sprite(
					_new_MainGroupTag.GROUND, i, j)
			if river_sprite == null:
				continue

			select_index = _ref_RandomNumber.get_int(0, 4)
			_ref_SwitchSprite.switch_sprite(
					river_sprite, _sprite_type[select_index])
			_ref_ObjectData.set_state(river_sprite, _object_state[select_index])


func _get_flow_path() -> Array:
	var x: int = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_X)
	var y: int = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y)
	var direction: Array = _flow_direction[_ref_RandomNumber.get_int(
			0, _flow_direction.size())]
	var flow_length: int = _ref_RandomNumber.get_int(
			_new_StyxData.MIN_LENGTH, _new_StyxData.MAX_LENGTH)
	var flow_path: Array = [[x, y]]

	for _i in range(flow_length):
		x = x + direction[0]
		y = y + direction[1]
		if not _new_CoordCalculator.is_inside_dungeon(x, y):
			break
		flow_path.push_back([x, y])
	return flow_path


func _rotate_sprite(flow_path: Array) -> void:
	var ground_sprite: Sprite
	var select_index: int

	for i in range(1, flow_path.size()):
		ground_sprite = _ref_DungeonBoard.get_sprite(
				_new_MainGroupTag.GROUND, flow_path[i][0], flow_path[i][1])
		if ground_sprite == null:
			continue

		if flow_path[i][0] == flow_path[i - 1][0]:
			if flow_path[i][1] > flow_path[i - 1][1]:
				select_index = 0
			else:
				select_index = 1
		elif flow_path[i][1] == flow_path[i - 1][1]:
			if flow_path[i][0] > flow_path[i - 1][0]:
				select_index = 3
			else:
				select_index = 2

		_ref_SwitchSprite.switch_sprite(
				ground_sprite, _sprite_type[select_index])
		_ref_ObjectData.set_state(ground_sprite, _object_state[select_index])
