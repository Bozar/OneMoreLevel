extends "res://library/game_progress/ProgressTemplate.gd"


var _new_BalloonData := preload("res://library/npc_data/BalloonData.gd").new()

var _wind_duration: int = 0
var _count_trap: int = 0
var _valid_direction: Array
var _int_to_state: Dictionary = {}
var _state_to_int: Dictionary = {}
var _state_to_sprite: Dictionary = {}
var _wind_forecast: Array = []


func _init(parent_node: Node2D).(parent_node) -> void:
	_int_to_state = {
		+2: _new_ObjectStateTag.UP,
		-2: _new_ObjectStateTag.DOWN,
		+1: _new_ObjectStateTag.LEFT,
		-1: _new_ObjectStateTag.RIGHT,
		0: _new_ObjectStateTag.DEFAULT,
	}
	_state_to_sprite = {
		_new_ObjectStateTag.UP: _new_SpriteTypeTag.UP,
		_new_ObjectStateTag.DOWN: _new_SpriteTypeTag.DOWN,
		_new_ObjectStateTag.LEFT: _new_SpriteTypeTag.LEFT,
		_new_ObjectStateTag.RIGHT: _new_SpriteTypeTag.RIGHT,
	}
	_new_ArrayHelper.reverse_key_value_in_dict(_int_to_state, _state_to_int)

	_valid_direction = _state_to_sprite.keys()
	_new_ArrayHelper.filter_element(_valid_direction, self, "_filter_direction",
			[])

	_wind_forecast.resize(2)


func renew_world(_pc_x: int, _pc_y: int) -> void:
	var ground: Sprite

	if _wind_duration < 1:
		_set_wind_direction()
		_wind_duration = _new_BalloonData.WIND_DURATION
	else:
		ground = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.GROUND,
				0, _wind_duration)
		_ref_SwitchSprite.switch_sprite(ground, _new_SpriteTypeTag.DEFAULT)
		_wind_duration -= 1


func remove_trap(_trap: Sprite, x: int, y: int) -> void:
	_ref_CreateObject.create(_spr_Floor,
			_new_MainGroupTag.GROUND, _new_SubGroupTag.FLOOR, x, y)

	_count_trap += 1
	if _count_trap == _new_BalloonData.MAX_TRAP:
		_ref_EndGame.player_win()


func _set_wind_direction() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var index: int
	var candidate: Array = []
	var ground: Sprite

	if _wind_forecast[0] == null:
		index = _ref_RandomNumber.get_int(0, _valid_direction.size())
		_wind_forecast[0] = _valid_direction[index]
	else:
		_wind_forecast[0] = _wind_forecast[1]

	for i in _valid_direction:
		if i != _int_to_state[0 - _state_to_int[_wind_forecast[0]]]:
			candidate.push_back(i)
	_new_ArrayHelper.duplicate_element(candidate, self, "_dup_set_wind",
			[_wind_forecast[0]])
	_new_ArrayHelper.rand_picker(candidate, 1, _ref_RandomNumber)
	_wind_forecast[1] = candidate[0]

	_ref_ObjectData.set_state(pc, _wind_forecast[0])
	_ref_SwitchSprite.switch_sprite(pc, _state_to_sprite[_wind_forecast[0]])

	for x in range(0, 2):
		ground = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.GROUND, x, 0)
		_ref_SwitchSprite.switch_sprite(ground, _wind_forecast[x])
	for y in range(1, 3):
		ground = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.GROUND, 0, y)
		_ref_SwitchSprite.switch_sprite(ground, _wind_forecast[0])


func _filter_direction(source: Array, index: int, _opt_arg: Array) -> bool:
	return source[index] != _new_ObjectStateTag.DEFAULT


func _dup_set_wind(source: Array, index: int, opt_arg: Array) -> int:
	var direction: String = opt_arg[0]
	return 1 if (source[index] == direction) else 2
