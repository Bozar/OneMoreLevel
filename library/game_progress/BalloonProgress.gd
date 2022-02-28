extends Game_ProgressTemplate


var _wind_duration: int = 0
var _wind_forecast: Array = []


func _init(parent_node: Node2D).(parent_node) -> void:
	_wind_forecast.resize(2)


func renew_world(_pc_x: int, _pc_y: int) -> void:
	var ground: Sprite

	if _wind_duration < 1:
		_set_wind_direction()
		_wind_duration = Game_BalloonData.WIND_DURATION
	else:
		ground = _ref_DungeonBoard.get_ground(0, _wind_duration)
		_ref_SwitchSprite.set_sprite(ground, Game_SpriteTypeTag.DEFAULT)
		_wind_duration -= 1


func _set_wind_direction() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var index: int
	var candidate: Array = []
	var ground: Sprite

	if _wind_forecast[0] == null:
		index = _ref_RandomNumber.get_int(0,
				Game_StateTag.VALID_DIRECTION.size())
		_wind_forecast[0] = Game_StateTag.VALID_DIRECTION[index]
	else:
		_wind_forecast[0] = _wind_forecast[1]

	for i in Game_StateTag.VALID_DIRECTION:
		if i != Game_StateTag.OPPOSITE_DIRECTION[_wind_forecast[0]]:
			candidate.push_back(i)
	Game_ArrayHelper.duplicate_element(candidate, self, "_dup_set_wind",
			[_wind_forecast[0]])
	Game_ArrayHelper.rand_picker(candidate, 1, _ref_RandomNumber)
	_wind_forecast[1] = candidate[0]

	_ref_ObjectData.set_state(pc, _wind_forecast[0])
	_ref_SwitchSprite.set_sprite(pc, Game_StateTag.STATE_TO_SPRITE[
			_wind_forecast[0]])

	for x in range(0, 2):
		ground = _ref_DungeonBoard.get_ground(x, 0)
		_ref_SwitchSprite.set_sprite(ground, Game_StateTag.STATE_TO_SPRITE[
				_wind_forecast[x]])
	for y in range(1, 3):
		ground = _ref_DungeonBoard.get_ground(0, y)
		_ref_SwitchSprite.set_sprite(ground, Game_StateTag.STATE_TO_SPRITE[
				_wind_forecast[0]])


func _dup_set_wind(source: Array, index: int, opt_arg: Array) -> int:
	var direction: int = opt_arg[0]
	return 1 if (source[index] == direction) else 2
