extends "res://library/game_progress/ProgressTemplate.gd"


const OBJECT_STATE_TAG := preload("res://library/ObjectStateTag.gd")
const SPRITE_TYPE_TAG := preload("res://library/SpriteTypeTag.gd")

const STATE_TO_SPRITE: Dictionary = {
	OBJECT_STATE_TAG.UP: SPRITE_TYPE_TAG.UP,
	OBJECT_STATE_TAG.DOWN: SPRITE_TYPE_TAG.DOWN,
	OBJECT_STATE_TAG.LEFT: SPRITE_TYPE_TAG.LEFT,
	OBJECT_STATE_TAG.RIGHT: SPRITE_TYPE_TAG.RIGHT,
}
const VALID_DIRECTION: Array = [
	OBJECT_STATE_TAG.UP,
	OBJECT_STATE_TAG.DOWN,
	OBJECT_STATE_TAG.LEFT,
	OBJECT_STATE_TAG.RIGHT,
]
const OPPOSITE_DIRECTION: Dictionary = {
	OBJECT_STATE_TAG.UP: OBJECT_STATE_TAG.DOWN,
	OBJECT_STATE_TAG.DOWN: OBJECT_STATE_TAG.UP,
	OBJECT_STATE_TAG.LEFT: OBJECT_STATE_TAG.RIGHT,
	OBJECT_STATE_TAG.RIGHT: OBJECT_STATE_TAG.LEFT,
}

var _new_BalloonData := preload("res://library/npc_data/BalloonData.gd").new()

var _wind_duration: int = 0
var _count_trap: int = 0
var _wind_forecast: Array = []


func _init(parent_node: Node2D).(parent_node) -> void:
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
		index = _ref_RandomNumber.get_int(0, VALID_DIRECTION.size())
		_wind_forecast[0] = VALID_DIRECTION[index]
	else:
		_wind_forecast[0] = _wind_forecast[1]

	for i in VALID_DIRECTION:
		if i != OPPOSITE_DIRECTION[_wind_forecast[0]]:
			candidate.push_back(i)
	_new_ArrayHelper.duplicate_element(candidate, self, "_dup_set_wind",
			[_wind_forecast[0]])
	_new_ArrayHelper.rand_picker(candidate, 1, _ref_RandomNumber)
	_wind_forecast[1] = candidate[0]

	_ref_ObjectData.set_state(pc, _wind_forecast[0])
	_ref_SwitchSprite.switch_sprite(pc, STATE_TO_SPRITE[_wind_forecast[0]])

	for x in range(0, 2):
		ground = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.GROUND, x, 0)
		_ref_SwitchSprite.switch_sprite(ground, _wind_forecast[x])
	for y in range(1, 3):
		ground = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.GROUND, 0, y)
		_ref_SwitchSprite.switch_sprite(ground, _wind_forecast[0])


func _dup_set_wind(source: Array, index: int, opt_arg: Array) -> int:
	var direction: String = opt_arg[0]
	return 1 if (source[index] == direction) else 2
