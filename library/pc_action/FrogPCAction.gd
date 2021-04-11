extends "res://library/pc_action/PCActionTemplate.gd"


var _new_FrogData := preload("res://library/npc_data/FrogData.gd").new()

var _pass_next_turn: bool
var _step_counter: int = 0


func _init(parent_node: Node2D).(parent_node) -> void:
	_fov_render_range = _new_FrogData.RENDER_RANGE


func allow_input() -> bool:
	return not _pass_next_turn


func pass_turn() -> void:
	_pass_next_turn = false


func is_npc() -> bool:
	var reach_x: int = (_target_position[0] - _source_position[0]) * 2 \
			+ _source_position[0]
	var reach_y: int = (_target_position[1] - _source_position[1]) * 2 \
			+ _source_position[1]

	if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR,
			_target_position[0], _target_position[1]):
		return true
	elif _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR,
			reach_x, reach_y):
		_target_position[0] = reach_x
		_target_position[1] = reach_y
		return true
	return false


func is_building() -> bool:
	return false


func is_trap() -> bool:
	return false


func move() -> void:
	if _is_in_swamp(_source_position[0], _source_position[1]):
		_step_counter += 1
		if _step_counter >= _new_FrogData.SINK_IN_MUD:
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
	_ref_CountDown.add_count(_new_FrogData.RESTORE_TURN)


func wait() -> void:
	_set_pc_state(_new_ObjectStateTag.PASSIVE)
	.wait()


func reset_state() -> void:
	_set_pc_state(_new_ObjectStateTag.DEFAULT)
	.reset_state()


func switch_sprite() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var x: int = _source_position[0]
	var y: int = _source_position[1]

	if _is_in_swamp(x, y):
		if _step_counter == _new_FrogData.SINK_IN_MUD - 1:
			_ref_SwitchSprite.switch_sprite(pc, _new_SpriteTypeTag.PASSIVE_1)
		else:
			_ref_SwitchSprite.switch_sprite(pc, _new_SpriteTypeTag.PASSIVE)
	else:
		_ref_SwitchSprite.switch_sprite(pc, _new_SpriteTypeTag.DEFAULT)


func _is_in_swamp(x: int, y: int) -> bool:
	return _ref_DungeonBoard.has_sprite_with_sub_tag(
			_new_MainGroupTag.GROUND, _new_SubGroupTag.SWAMP, x, y)


func _set_pc_state(state_tag: String) -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	_ref_ObjectData.set_state(pc, state_tag)


func _block_line_of_sight(x: int, y: int, _opt_arg: Array) -> bool:
	return _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR, x, y)
