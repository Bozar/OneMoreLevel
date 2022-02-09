extends Game_PCActionTemplate


const TELEPORT_X := {
	-1: Game_DungeonSize.MAX_X - 1,
	Game_DungeonSize.MAX_X: 0,
}
const TELEPORT_Y := {
	-1: Game_DungeonSize.MAX_Y - 1,
	Game_DungeonSize.MAX_Y: 0,
}

var _count_beacon := Game_BalloonData.MAX_TRAP


func _init(parent_node: Node2D).(parent_node) -> void:
	_fov_render_range = Game_BalloonData.RENDER_RANGE


func switch_sprite() -> void:
	pass


func render_fov() -> void:
	var pos: Game_IntCoord

	_set_render_sprites()
	if _ref_GameSetting.get_show_full_map():
		_render_without_fog_of_war()
		return

	Game_ShadowCastFOV.set_field_of_view(
			Game_DungeonSize.MAX_X, Game_DungeonSize.MAX_Y,
			_source_position.x, _source_position.y, _fov_render_range,
			self, "_block_line_of_sight", [])

	for mtag in RENDER_SPRITES:
		for i in RENDER_SPRITES[mtag]:
			if mtag != Game_MainTag.TRAP:
				pos = Game_ConvertCoord.vector_to_coord(i.position)
				_set_sprite_color(pos.x, pos.y, mtag, Game_ShadowCastFOV,
						"is_in_sight")


func wait() -> void:
	var add_count := false

	_wind_blow()
	if _ref_DungeonBoard.has_trap(_source_position.x, _source_position.y):
		add_count = _reach_destination(_source_position.x, _source_position.y)
	_end_turn_or_game(add_count)


func interact_with_building() -> void:
	_bounce_off(_source_position.x, _source_position.y,
			_target_position.x, _target_position.y)
	_end_turn_or_game(false)


func interact_with_trap() -> void:
	var add_count: bool

	_ref_DungeonBoard.move_sprite(Game_MainTag.ACTOR,
			_source_position.x, _source_position.y,
			_target_position.x, _target_position.y)
	add_count = _reach_destination(_target_position.x, _target_position.y)
	_end_turn_or_game(add_count)


func move() -> void:
	_ref_DungeonBoard.move_sprite(Game_MainTag.ACTOR,
			_source_position.x, _source_position.y,
			_target_position.x, _target_position.y)
	_end_turn_or_game(false)


func set_target_position(direction: String) -> void:
	_wind_blow()
	.set_target_position(direction)
	_target_position = _try_move_over_border(
			_target_position.x, _target_position.y)


func _wind_blow() -> void:
	var pc := _ref_DungeonBoard.get_pc()
	var wind_direction: Array = Game_StateTag.DIRECTION_TO_COORD[ \
			_ref_ObjectData.get_state(pc)]
	var new_position := Game_IntCoord.new(
		_source_position.x + wind_direction[0],
		_source_position.y + wind_direction[1]
	)

	new_position = _try_move_over_border(new_position.x, new_position.y)
	if _ref_DungeonBoard.has_building(new_position.x, new_position.y):
		_bounce_off(_source_position.x, _source_position.y,
				new_position.x, new_position.y)
	else:
		_ref_DungeonBoard.move_sprite(Game_MainTag.ACTOR,
				_source_position.x, _source_position.y,
				new_position.x, new_position.y)
	_source_position = Game_ConvertCoord.vector_to_coord(pc.position)


func _try_move_over_border(x: int, y: int) -> Game_IntCoord:
	if TELEPORT_X.has(x):
		x = TELEPORT_X[x]
	if TELEPORT_Y.has(y):
		y = TELEPORT_Y[y]
	return Game_IntCoord.new(x, y)


func _reach_destination(x: int, y: int) -> bool:
	var beacon := _ref_DungeonBoard.get_trap(x, y)
	var add_count := false

	if _ref_ObjectData.verify_state(beacon, Game_StateTag.DEFAULT):
		_count_beacon -= 1
		_ref_SwitchSprite.set_sprite(beacon, Game_SpriteTypeTag.PASSIVE)

	if not _ref_ObjectData.verify_state(beacon, Game_StateTag.PASSIVE):
		add_count = true
		_reactive_beacon()
		_set_beacon_state(beacon, Game_StateTag.PASSIVE)
	return add_count


func _bounce_off(pc_x: int, pc_y: int, wall_x: int, wall_y: int) -> void:
	var mirror := Game_CoordCalculator.get_mirror_image(wall_x, wall_y,
			pc_x, pc_y)
	var new_position := _try_move_over_border(mirror.x, mirror.y)

	if not _ref_DungeonBoard.has_building(new_position.x, new_position.y):
		_ref_DungeonBoard.move_sprite(Game_MainTag.ACTOR, pc_x, pc_y,
				new_position.x, new_position.y)


func _reactive_beacon() -> void:
	for i in _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.TREASURE):
		if _ref_ObjectData.verify_state(i, Game_StateTag.PASSIVE):
			_set_beacon_state(i, Game_StateTag.ACTIVE)


func _set_beacon_state(beacon: Sprite, state: String) -> void:
	match state:
		Game_StateTag.ACTIVE:
			_ref_ObjectData.set_state(beacon, state)
			_ref_Palette.set_default_color(beacon, Game_MainTag.TRAP)
		Game_StateTag.PASSIVE:
			_ref_ObjectData.set_state(beacon, state)
			_ref_Palette.set_dark_color(beacon, Game_MainTag.TRAP)


func _end_turn_or_game(add_count: bool) -> void:
	var player_win: bool

	if _count_beacon == 0:
		player_win = true
	elif _ref_CountDown.get_count(true) == 1:
		if add_count:
			player_win = false
		else:
			player_win = _count_beacon < Game_BalloonData.MAX_REMAINING_TRAP
	else:
		player_win = false

	if player_win:
		_ref_EndGame.player_win()
	else:
		if add_count:
			if _count_beacon > Game_BalloonData.STAGE_1_BEACON:
				_ref_CountDown.add_count(Game_BalloonData.STAGE_1_RESTORE)
			elif _count_beacon > Game_BalloonData.STAGE_2_BEACON:
				_ref_CountDown.add_count(Game_BalloonData.STAGE_2_RESTORE)
			else:
				_ref_CountDown.add_count(Game_BalloonData.STAGE_3_RESTORE)
		end_turn = true
