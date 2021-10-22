extends Game_PCActionTemplate


var _pass_next_turn: bool
var _step_counter: int = 0


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

	if _ref_DungeonBoard.has_actor(_target_position.x, _target_position.y):
		return true
	elif _ref_DungeonBoard.has_actor(reach_x, reach_y):
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
	return _ref_DungeonBoard.has_sprite_with_sub_tag(Game_SubTag.SWAMP, x, y)


func _set_pc_state(state_tag: String) -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	_ref_ObjectData.set_state(pc, state_tag)


func _block_line_of_sight(x: int, y: int, _opt_arg: Array) -> bool:
	return _ref_DungeonBoard.has_actor(x, y)


func _post_process_fov(pc_x: int, pc_y: int) -> void:
	var frogs := _ref_DungeonBoard.get_npc()
	var hide_count: int
	var pos: Game_IntCoord
	var find_floor: Sprite

	Game_ArrayHelper.filter_element(frogs, self, "_hide_frog", [pc_x, pc_y])
	hide_count = (frogs.size() * Game_FrogData.HIDE_FROG_PERCENT) as int
	Game_ArrayHelper.rand_picker(frogs, hide_count, _ref_RandomNumber)

	for i in frogs:
		pos = Game_ConvertCoord.vector_to_coord(i.position)
		i.visible = false
		find_floor = _ref_DungeonBoard.get_ground(pos.x, pos.y)
		find_floor.visible = true


func _hide_frog(source: Array, index: int, opt_arg: Array) -> bool:
	var pos: Game_IntCoord
	var pc_x: int = opt_arg[0]
	var pc_y: int = opt_arg[1]

	if source[index].is_in_group(Game_SubTag.FROG_PRINCESS):
		return false

	pos = Game_ConvertCoord.vector_to_coord(source[index].position)
	return not Game_CoordCalculator.is_inside_range(pos.x, pos.y, pc_x, pc_y,
			Game_FrogData.RENDER_RANGE)
