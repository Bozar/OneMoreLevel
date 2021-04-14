extends "res://library/pc_action/PCActionTemplate.gd"


const TELEPORT_X: Dictionary = {
	-1: DUNGEON_SIZE.MAX_X - 1,
	DUNGEON_SIZE.MAX_X: 0,
}
const TELEPORT_Y: Dictionary = {
	-1: DUNGEON_SIZE.MAX_Y - 1,
	DUNGEON_SIZE.MAX_Y: 0,
}

var _new_BalloonData := preload("res://library/npc_data/BalloonData.gd").new()

var _count_beacon: int = _new_BalloonData.MAX_TRAP


func _init(parent_node: Node2D).(parent_node) -> void:
	_fov_render_range = _new_BalloonData.RENDER_RANGE


func switch_sprite() -> void:
	pass


func render_fov() -> void:
	if _ref_GameSetting.get_show_full_map():
		_render_without_fog_of_war()
		return

	_new_ShadowCastFOV.set_field_of_view(
			_source_position[0], _source_position[1], _fov_render_range,
			self, "_block_line_of_sight", [])

	for x in range(_new_DungeonSize.MAX_X):
		for y in range(_new_DungeonSize.MAX_Y):
			for i in _new_MainGroupTag.DUNGEON_OBJECT:
				if i != _new_MainGroupTag.TRAP:
					_set_sprite_color(x, y, i, "",
							_new_ShadowCastFOV, "is_in_sight")


func wait() -> void:
	var add_count: bool = false

	_wind_blow()
	if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.TRAP,
			_source_position[0], _source_position[1]):
		add_count = _reach_destination(_source_position[0], _source_position[1])

	_end_turn_or_game()
	if add_count:
		_ref_CountDown.add_count(_new_BalloonData.RESTORE_TURN)


func interact_with_building() -> void:
	_bounce_off(_source_position[0], _source_position[1],
			_target_position[0], _target_position[1])
	_end_turn_or_game()


func interact_with_trap() -> void:
	var add_count: bool

	_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR,
			_source_position[0], _source_position[1],
			_target_position[0], _target_position[1])
	add_count = _reach_destination(_target_position[0], _target_position[1])

	_end_turn_or_game()
	if add_count:
		_ref_CountDown.add_count(_new_BalloonData.RESTORE_TURN)


func move() -> void:
	_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR,
			_source_position[0], _source_position[1],
			_target_position[0], _target_position[1])
	_end_turn_or_game()


func set_target_position(direction: String) -> void:
	_wind_blow()
	.set_target_position(direction)
	_target_position = _try_move_over_border(_target_position)


func _wind_blow() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.ACTOR,
			_source_position[0], _source_position[1])
	var wind_direction: Array = _new_ObjectStateTag.DIRECTION_TO_COORD[ \
			_ref_ObjectData.get_state(pc)]
	var new_position: Array = [
		_source_position[0] + wind_direction[0],
		_source_position[1] + wind_direction[1]
	]

	new_position = _try_move_over_border(new_position)
	if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING,
			new_position[0], new_position[1]):
		_bounce_off(_source_position[0], _source_position[1],
				new_position[0], new_position[1])
	else:
		_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR,
				_source_position[0], _source_position[1],
				new_position[0], new_position[1])
	_source_position = _new_ConvertCoord.vector_to_array(pc.position)


func _try_move_over_border(position: Array) -> Array:
	var x: int = position[0]
	var y: int = position[1]

	if TELEPORT_X.has(x):
		x = TELEPORT_X[x]
	if TELEPORT_Y.has(y):
		y = TELEPORT_Y[y]
	return [x, y]


func _reach_destination(x: int, y: int) -> bool:
	var beacon: Sprite = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.TRAP,
			x, y)
	var add_count: bool = false

	if _ref_ObjectData.verify_state(beacon, _new_ObjectStateTag.DEFAULT):
		_count_beacon -= 1
		_ref_SwitchSprite.switch_sprite(beacon, _new_SpriteTypeTag.PASSIVE)

	if not _ref_ObjectData.verify_state(beacon, _new_ObjectStateTag.PASSIVE):
		add_count = true
		_reactive_beacon()
		_set_beacon_state(beacon, _new_ObjectStateTag.PASSIVE)
	return add_count


func _bounce_off(pc_x: int, pc_y: int, wall_x: int, wall_y: int) -> void:
	var new_position: Array = _new_CoordCalculator.get_mirror_image(
			wall_x, wall_y, pc_x, pc_y, true)
	new_position = _try_move_over_border(new_position)

	if not _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING,
			new_position[0], new_position[1]):
		_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR, pc_x, pc_y,
				new_position[0], new_position[1])


func _reactive_beacon() -> void:
	for i in _ref_DungeonBoard.get_sprites_by_tag(_new_SubGroupTag.TREASURE):
		if _ref_ObjectData.verify_state(i, _new_ObjectStateTag.PASSIVE):
			_set_beacon_state(i, _new_ObjectStateTag.ACTIVE)


func _set_beacon_state(beacon: Sprite, state: String) -> void:
	match state:
		_new_ObjectStateTag.ACTIVE:
			_ref_ObjectData.set_state(beacon, state)
			_ref_Palette.set_default_color(beacon, _new_MainGroupTag.TRAP)
		_new_ObjectStateTag.PASSIVE:
			_ref_ObjectData.set_state(beacon, state)
			_ref_Palette.set_dark_color(beacon, _new_MainGroupTag.TRAP)


func _end_turn_or_game() -> void:
	if _count_beacon == 0:
		_ref_EndGame.player_win()
	elif (_ref_CountDown.get_count(true) == 1) \
			and (_count_beacon < _new_BalloonData.MAX_REMAINING_TRAP):
		_ref_EndGame.player_win()
	else:
		end_turn = true
