extends "res://library/game_progress/ProgressTemplate.gd"


var _new_StyxData := preload("res://library/npc_data/StyxData.gd").new()

var _sprite_type: Array
var _object_state: Array

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
	if _countdown == _new_StyxData.RENEW_MAP:
		_countdown = 0
		_switch_ground()
	_countdown += 1


func _switch_ground() -> void:
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
