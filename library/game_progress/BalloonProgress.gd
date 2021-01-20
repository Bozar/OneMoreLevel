extends "res://library/game_progress/ProgressTemplate.gd"


var _new_BalloonData := preload("res://library/npc_data/BalloonData.gd").new()
var _new_ArrayHelper := preload("res://library/ArrayHelper.gd").new()

var _wind_duration: int = 0
var _count_trap: int = 0
var _int_to_state: Dictionary = {}
var _state_to_int: Dictionary = {}
var _state_to_sprite: Dictionary


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


func renew_world(_pc_x: int, _pc_y: int) -> void:
	if _wind_duration < 1:
		_set_wind_direction()
		_wind_duration = _new_BalloonData.WIND_DURATION
	else:
		_wind_duration -= 1


func remove_trap(_trap: Sprite, _x: int, _y: int) -> void:
	_count_trap += 1
	if _count_trap == _new_BalloonData.MAX_TRAP:
		_ref_EndGame.player_win()


func _set_wind_direction() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var current_direction: String = _ref_ObjectData.get_state(pc)
	var candidate: Array = []
	var new_direction: String

	for i in _state_to_int.keys():
		if (i != _new_ObjectStateTag.DEFAULT) \
				and (i != _int_to_state[0 - _state_to_int[current_direction]]):
			candidate.push_back(i)

	_new_ArrayHelper.duplicate_element(candidate, self, "_dup_set_wind",
			[current_direction])
	_new_ArrayHelper.random_picker(candidate, 1, _ref_RandomNumber)
	new_direction = candidate[0]

	_ref_ObjectData.set_state(pc, new_direction)
	_ref_SwitchSprite.switch_sprite(pc, _state_to_sprite[new_direction])


func _dup_set_wind(source: Array, index: int, opt_arg: Array) -> int:
	var direction: String = opt_arg[0]
	return 1 if (source[index] == direction) else 2
