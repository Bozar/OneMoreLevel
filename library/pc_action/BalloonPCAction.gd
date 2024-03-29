extends Game_PCActionTemplate


const TELEPORT_X := {
	# | ←
	-1: Game_DungeonSize.MAX_X - 1,
	# → |
	Game_DungeonSize.MAX_X: 0,
	# | ← ... # |
	1 - Game_DungeonSize.MAX_X: 1,
	# | # ... → |
	(Game_DungeonSize.MAX_X - 1) * 2: Game_DungeonSize.MAX_X - 2,
}
const TELEPORT_Y := {
	-1: Game_DungeonSize.MAX_Y - 1,
	Game_DungeonSize.MAX_Y: 0,
	1 - Game_DungeonSize.MAX_Y: 1,
	(Game_DungeonSize.MAX_Y - 1) * 2: Game_DungeonSize.MAX_Y - 2,
}

var _count_beacon := Game_BalloonData.MAX_TRAP
var _arrow_sprites := []


func _init(parent_node: Node2D).(parent_node) -> void:
	_fov_render_range = Game_BalloonData.RENDER_RANGE


func switch_sprite() -> void:
	pass


func init_data() -> void:
	_init_arrow_sprites()


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
				pos = Game_ConvertCoord.sprite_to_coord(i)
				_set_sprite_color(pos.x, pos.y, mtag, Game_ShadowCastFOV,
						"is_in_sight")

	for i in _arrow_sprites:
		_ref_Palette.set_default_color(i, Game_MainTag.GROUND)


func wait() -> void:
	var add_count := false

	_wind_blow()
	if _ref_DungeonBoard.has_trap(_source_position):
		add_count = _reach_destination(_source_position)
	_end_turn_or_game(add_count)


func interact_with_building() -> void:
	_bounce_off(_source_position, _target_position)
	_end_turn_or_game(false)


func interact_with_trap() -> void:
	var add_count: bool

	_ref_DungeonBoard.move_actor(_source_position, _target_position)
	add_count = _reach_destination(_target_position)
	_end_turn_or_game(add_count)


func move() -> void:
	_ref_DungeonBoard.move_actor(_source_position, _target_position)
	_end_turn_or_game(false)


func set_target_position(direction: String) -> void:
	_wind_blow()
	.set_target_position(direction)
	_target_position = _try_move_over_border(_target_position)


func _wind_blow() -> void:
	var pc := _ref_DungeonBoard.get_pc()
	var wind_direction: Array = Game_StateTag.DIRECTION_TO_COORD[ \
			_ref_ObjectData.get_state(pc)]
	var new_position := Game_IntCoord.new(
		_source_position.x + wind_direction[0],
		_source_position.y + wind_direction[1]
	)

	new_position = _try_move_over_border(new_position)
	if _ref_DungeonBoard.has_building(new_position):
		_bounce_off(_source_position, new_position)
	else:
		_ref_DungeonBoard.move_actor(_source_position, new_position)
	_source_position = Game_ConvertCoord.sprite_to_coord(pc)


func _try_move_over_border(coord: Game_IntCoord) -> Game_IntCoord:
	var x := coord.x
	var y := coord.y

	if TELEPORT_X.has(coord.x):
		x = TELEPORT_X[coord.x]
	if TELEPORT_Y.has(coord.y):
		y = TELEPORT_Y[coord.y]
	return Game_IntCoord.new(x, y)


func _reach_destination(coord: Game_IntCoord) -> bool:
	var beacon := _ref_DungeonBoard.get_trap(coord)
	var add_count := false

	if _ref_ObjectData.verify_state(beacon, Game_StateTag.DEFAULT):
		_count_beacon -= 1
		_ref_SwitchSprite.set_sprite(beacon, Game_SpriteTypeTag.PASSIVE)

	if not _ref_ObjectData.verify_state(beacon, Game_StateTag.PASSIVE):
		add_count = true
		_reactive_beacon()
		_set_beacon_state(beacon, Game_StateTag.PASSIVE)
	return add_count


func _bounce_off(pc_coord: Game_IntCoord, wall_coord: Game_IntCoord) -> void:
	var mirror := Game_CoordCalculator.get_mirror_image(wall_coord, pc_coord)
	var new_position := _try_move_over_border(mirror)

	if not _ref_DungeonBoard.has_building(new_position):
		_ref_DungeonBoard.move_actor(pc_coord, new_position)


func _reactive_beacon() -> void:
	for i in _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.TREASURE):
		if _ref_ObjectData.verify_state(i, Game_StateTag.PASSIVE):
			_set_beacon_state(i, Game_StateTag.ACTIVE)


func _set_beacon_state(beacon: Sprite, state: int) -> void:
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


func _init_arrow_sprites() -> void:
	_arrow_sprites = _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.ARROW)
