extends Game_PCActionTemplate


var _pass_next_turn: bool
var _step_counter := 0
var _lighted_dungeon := {}


func _init(parent_node: Node2D).(parent_node) -> void:
	_fov_render_range = Game_FrogData.RENDER_RANGE
	Game_DungeonSize.init_dungeon_grids(_lighted_dungeon, false)


func allow_input() -> bool:
	return not _pass_next_turn


func pass_turn() -> void:
	_pass_next_turn = false


func is_npc() -> bool:
	var reach_x: int = (_target_position.x - _source_position.x) * 2 \
			+ _source_position.x
	var reach_y: int = (_target_position.y - _source_position.y) * 2 \
			+ _source_position.y

	if _ref_DungeonBoard.has_actor(_target_position):
		return true
	elif _ref_DungeonBoard.has_actor_xy(reach_x, reach_y):
		_target_position.x = reach_x
		_target_position.y = reach_y
		return true
	return false


func is_building() -> bool:
	return false


func is_trap() -> bool:
	return false


func move() -> void:
	if _is_in_swamp(_source_position):
		_step_counter += 1
		if _step_counter >= Game_FrogData.SINK_IN_MUD:
			_pass_next_turn = true
			_step_counter = 0
	.move()


func attack() -> void:
	var pc := _ref_DungeonBoard.get_pc()

	_step_counter = 0
	_set_lighted_dungeon()
	.attack()

	# PC's bool state is set in FrogProgress. End game after frog princess is
	# removed.
	if _ref_ObjectData.get_bool(pc):
		_ref_EndGame.player_win()
	else:
		_ref_CountDown.add_count(Game_FrogData.RESTORE_TURN)


func wait() -> void:
	_set_pc_state(Game_StateTag.PASSIVE)
	.wait()


func reset_state() -> void:
	_set_pc_state(Game_StateTag.DEFAULT)
	.reset_state()


func render_fov() -> void:
	var pc_pos := _ref_DungeonBoard.get_pc_coord()
	var this_pos: Game_IntCoord

	_set_render_sprites()
	if _ref_GameSetting.get_show_full_map():
		_render_without_fog_of_war()
		return

	Game_ShadowCastFOV.set_field_of_view(
			Game_DungeonSize.MAX_X, Game_DungeonSize.MAX_Y,
			pc_pos.x, pc_pos.y, _fov_render_range,
			self, "_block_line_of_sight", [])

	for mtag in RENDER_SPRITES:
		for i in RENDER_SPRITES[mtag]:
			this_pos = Game_ConvertCoord.sprite_to_coord(i)
			_set_sprite_color(this_pos.x, this_pos.y, mtag, self,
					"_is_in_sight")
			if not _is_in_sight(this_pos.x, this_pos.y):
				# Princess is visible. Ground is invisible.
				if _ref_DungeonBoard.has_sprite_with_sub_tag(
						Game_SubTag.FROG_PRINCESS, this_pos):
					i.visible = (mtag == Game_MainTag.ACTOR)
				# Knight is invisible. Ground is visible.
				else:
					i.visible = (mtag != Game_MainTag.ACTOR)


func switch_sprite() -> void:
	var pc := _ref_DungeonBoard.get_pc()

	if _is_in_swamp(_source_position):
		if _step_counter == Game_FrogData.SINK_IN_MUD - 1:
			_ref_SwitchSprite.set_sprite(pc, Game_SpriteTypeTag.PASSIVE_1)
		else:
			_ref_SwitchSprite.set_sprite(pc, Game_SpriteTypeTag.PASSIVE)
	else:
		_ref_SwitchSprite.set_sprite(pc, Game_SpriteTypeTag.DEFAULT)


func _is_in_swamp(coord: Game_IntCoord) -> bool:
	return _ref_DungeonBoard.has_sprite_with_sub_tag(Game_SubTag.SWAMP, coord)


func _set_pc_state(state_tag: int) -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	_ref_ObjectData.set_state(pc, state_tag)


func _block_line_of_sight(x: int, y: int, _opt_arg: Array) -> bool:
	return _ref_DungeonBoard.has_actor_xy(x, y)


func _is_in_sight(x: int, y: int) -> bool:
	return _lighted_dungeon[x][y] \
			or Game_ShadowCastFOV.is_in_sight(x, y)


func _set_lighted_dungeon() -> void:
	var target := _ref_DungeonBoard.get_actor(_target_position)
	var neighbor: Array
	var ground: Sprite

	if target.is_in_group(Game_SubTag.FROG_PRINCESS):
		return

	neighbor = Game_CoordCalculator.get_neighbor(_target_position,
			Game_FrogData.LIGHTED_RANGE, true)
	# Refer: FrogProgress._submerge_land(). Do not remove lighted lands.
	for i in neighbor:
		ground = _ref_DungeonBoard.get_ground(i)
		if ground.is_in_group(Game_SubTag.LAND):
			ground.remove_from_group(Game_SubTag.LAND)
			ground.add_to_group(Game_SubTag.FLOOR)
		_lighted_dungeon[i.x][i.y] = true
