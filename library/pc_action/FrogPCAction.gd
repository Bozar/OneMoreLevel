extends Game_PCActionTemplate


var _pass_next_turn: bool
var _step_counter := 0
var _visible_counter := 1


func _init(parent_node: Node2D).(parent_node) -> void:
	_fov_render_range = Game_FrogData.RENDER_RANGE


func allow_input() -> bool:
	return not _pass_next_turn


func pass_turn() -> void:
	_pass_next_turn = false


func is_npc() -> bool:
	var reach_x: int = (_target_position.x - _source_position.x) * 2 \
			+ _source_position.x
	var reach_y: int = (_target_position.y - _source_position.y) * 2 \
			+ _source_position.y

	if _ref_DungeonBoard.has_actor_xy(_target_position.x, _target_position.y):
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
	if _is_in_swamp(_source_position.x, _source_position.y):
		_step_counter += 1
		if _step_counter >= Game_FrogData.SINK_IN_MUD:
			_pass_next_turn = true
			_step_counter = 0
	.move()


func attack() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	_step_counter = 0
	_visible_counter = 1
	.attack()
	# PC's hit point is set in FrogProgress. End game after frog princess is
	# removed.
	if _ref_ObjectData.get_hit_point(pc) > 0:
		_ref_EndGame.player_win()
	_ref_CountDown.add_count(Game_FrogData.RESTORE_TURN)


func wait() -> void:
	_set_pc_state(Game_StateTag.PASSIVE)
	.wait()


func reset_state() -> void:
	_set_visible_counter()
	_set_pc_state(Game_StateTag.DEFAULT)
	.reset_state()


func switch_sprite() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var x: int = _source_position.x
	var y: int = _source_position.y

	if _is_in_swamp(x, y):
		if _step_counter == Game_FrogData.SINK_IN_MUD - 1:
			_ref_SwitchSprite.set_sprite(pc, Game_SpriteTypeTag.PASSIVE_1)
		else:
			_ref_SwitchSprite.set_sprite(pc, Game_SpriteTypeTag.PASSIVE)
	else:
		_ref_SwitchSprite.set_sprite(pc, Game_SpriteTypeTag.DEFAULT)


func _is_in_swamp(x: int, y: int) -> bool:
	return _ref_DungeonBoard.has_sprite_with_sub_tag_xy(Game_SubTag.SWAMP, x, y)


func _set_pc_state(state_tag: int) -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	_ref_ObjectData.set_state(pc, state_tag)


func _set_visible_counter() -> void:
	if _visible_counter > 0:
		_visible_counter -= 1
	else:
		_visible_counter = Game_FrogData.VISIBLE_COUNTER


func _block_line_of_sight(x: int, y: int, _opt_arg: Array) -> bool:
	return _ref_DungeonBoard.has_actor_xy(x, y)


func _post_process_fov(_pc_x: int, _pc_y: int) -> void:
	var pos: Game_IntCoord
	var find_floor: Sprite

	if _visible_counter < 1:
		return

	for i in _ref_DungeonBoard.get_npc():
		pos = Game_ConvertCoord.sprite_to_coord(i)
		if i.is_in_group(Game_SubTag.FROG_PRINCESS) \
				or Game_ShadowCastFOV.is_in_sight(pos.x, pos.y):
			continue
		i.visible = false
		find_floor = _ref_DungeonBoard.get_ground_xy(pos.x, pos.y)
		find_floor.visible = true


func _render_end_game(win: bool) -> void:
	_visible_counter = 0
	._render_end_game(win)
