extends Game_ProgressTemplate


const MAX_FORECAST_SLOT := 3

var _wind_duration: int = 0
var _wind_forecast: Array = []


func _init(parent_node: Node2D).(parent_node) -> void:
	_wind_forecast.resize(MAX_FORECAST_SLOT)


func renew_world(_pc_coord: Game_IntCoord) -> void:
	var ground: Sprite

	if _wind_duration < 1:
		_set_wind_direction()
		_wind_duration = Game_BalloonData.WIND_DURATION
	else:
		ground = _ref_DungeonBoard.get_ground_xy(0, _wind_duration)
		_ref_SwitchSprite.set_sprite(ground, Game_SpriteTypeTag.DEFAULT)
		_wind_duration -= 1


func _set_wind_direction() -> void:
	var last_index := MAX_FORECAST_SLOT - 1
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var ground: Sprite

	if _wind_forecast[0] == null:
		for i in range(0, _wind_forecast.size()):
			_set_direction_by_slot(i)
	else:
		for i in range(0, last_index):
			_wind_forecast[i] = _wind_forecast[i + 1]
		_set_direction_by_slot(last_index)

	_ref_ObjectData.set_state(pc, _wind_forecast[0])
	_ref_SwitchSprite.set_sprite(pc, Game_StateTag.STATE_TO_SPRITE[
			_wind_forecast[0]])

	for x in range(0, 2):
		ground = _ref_DungeonBoard.get_ground_xy(x, 0)
		_ref_SwitchSprite.set_sprite(ground, Game_StateTag.STATE_TO_SPRITE[
				_wind_forecast[x]])
	for y in range(1, 3):
		ground = _ref_DungeonBoard.get_ground_xy(0, y)
		_ref_SwitchSprite.set_sprite(ground, Game_StateTag.STATE_TO_SPRITE[
				_wind_forecast[0]])


func _set_direction_by_slot(slot: int) -> void:
	var valid_dirs := Game_StateTag.VALID_DIRECTION.duplicate()

	Game_ArrayHelper.filter_element(valid_dirs, self, "_filter_wind_direction",
			[slot])
	Game_ArrayHelper.rand_picker(valid_dirs, 1, _ref_RandomNumber)
	_wind_forecast[slot] = valid_dirs[0]


func _filter_wind_direction(source: Array, index: int, opt_arg: Array) -> bool:
	var forcast_slot: int = opt_arg[0]
	var is_opposite: bool
	var is_duplicated: bool
	var is_same: bool

	# No restriction for the first slot.
	if forcast_slot == 0:
		return true

	# The second slot cannot be opposite to the first one.
	is_opposite = Game_StateTag.is_opposite_direction(source[index],
			_wind_forecast[forcast_slot - 1])
	if forcast_slot == 1:
		return not is_opposite

	# Check whether the previous two slot are the same.
	is_duplicated = _wind_forecast[forcast_slot - 2] \
			== _wind_forecast[forcast_slot - 1]
	# Check whether the candidate and the previous slot are the same.
	is_same = source[index] == _wind_forecast[forcast_slot - 1]

	# Same as the second slot.
	if is_opposite:
		return false
	# There can be at most two slots of the same direction.
	elif is_duplicated:
		return not is_same
	# Two slots are less likely to be of the same direction.
	elif is_same:
		return _ref_RandomNumber.get_percent_chance(
				Game_BalloonData.CHANGE_DIRECTION)
	return true
