extends "res://library/game_progress/ProgressTemplate.gd"


var _new_BalloonData := preload("res://library/npc_data/BalloonData.gd").new()

var _wind_duration: int = 0
var _count_trap: int = 0
var _vailid_direction: Array
var _opposite_direction: Dictionary
var _state_to_sprite: Dictionary


func _init(parent_node: Node2D).(parent_node) -> void:
	_vailid_direction = [
		_new_ObjectStateTag.UP,
		_new_ObjectStateTag.DOWN,
		_new_ObjectStateTag.LEFT,
		_new_ObjectStateTag.RIGHT,
	]
	_opposite_direction = {
		_new_ObjectStateTag.UP: _new_ObjectStateTag.DOWN,
		_new_ObjectStateTag.DOWN: _new_ObjectStateTag.UP,
		_new_ObjectStateTag.LEFT: _new_ObjectStateTag.RIGHT,
		_new_ObjectStateTag.RIGHT: _new_ObjectStateTag.LEFT,
		_new_ObjectStateTag.DEFAULT: _new_ObjectStateTag.DEFAULT,
	}
	_state_to_sprite = {
		_new_ObjectStateTag.UP: _new_SpriteTypeTag.UP,
		_new_ObjectStateTag.DOWN: _new_SpriteTypeTag.DOWN,
		_new_ObjectStateTag.LEFT: _new_SpriteTypeTag.LEFT,
		_new_ObjectStateTag.RIGHT: _new_SpriteTypeTag.RIGHT,
	}


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
	var current_direction: String = _ref_ObjectData.get_state(_pc)
	var candidate: Array = []
	var new_index: int
	var new_direction: String

	for i in _vailid_direction:
		if i == _opposite_direction[current_direction]:
			continue
		elif i == current_direction:
			candidate.push_back(i)
		else:
			for _j in range(2):
				candidate.push_back(i)

	new_index = _ref_RandomNumber.get_int(0, candidate.size())
	new_direction = candidate[new_index]

	_ref_ObjectData.set_state(_pc, new_direction)
	_ref_SwitchSprite.switch_sprite(_pc, _state_to_sprite[new_direction])
