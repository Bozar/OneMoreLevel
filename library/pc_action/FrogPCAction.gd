extends "res://library/pc_action/PCActionTemplate.gd"


var _new_FrogData := preload("res://library/npc_data/FrogData.gd").new()

var _frog_sprite: Array
var _pass_next_turn: bool
var _step_counter: int = 0


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func allow_input() -> bool:
	if _is_checkmate():
		_ref_EndGame.player_lose()
		return false
	if _pass_next_turn:
		_pass_next_turn = false
		# A frog does not attack when PC is ACTIVE. The state is reset to
		# DEFAULT when PC's turn starts normally.
		_set_pc_state(_new_ObjectStateTag.ACTIVE)
		return false
	return true


func render_fov() -> void:
	var pos: Array

	if SHOW_FULL_MAP:
		return

	if _frog_sprite.size() == 0:
		_frog_sprite = _ref_DungeonBoard.get_npc()
	for i in _frog_sprite:
		pos = _new_ConvertCoord.vector_to_array(i.position)
		if _new_CoordCalculator.is_inside_range(pos[0], pos[1],
				_source_position[0], _source_position[1],
				_new_FrogData.RENDER_RANGE):
			_new_Palette.reset_color(i, _new_MainGroupTag.ACTOR)
		else:
			i.modulate = _new_Palette.SHADOW


func is_npc() -> bool:
	var reach_x: int = (_target_position[0] - _source_position[0]) * 2 \
			+ _source_position[0]
	var reach_y: int = (_target_position[1] - _source_position[1]) * 2 \
			+ _source_position[1]

	if _ref_DangerZone.is_in_danger(_source_position[0], _source_position[1]):
		return false
	elif _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR,
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
	var sor_x: int = _source_position[0]
	var sor_y: int = _source_position[1]
	var tar_x: int = _target_position[0]
	var tar_y: int = _target_position[1]

	# If PC is in danger zone, `is_npc()` does not check whether target position
	# is occupied by an NPC or is dangerous.
	if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR, tar_x, tar_y) \
			or _ref_DangerZone.is_in_danger(tar_x, tar_y):
		return

	if _ref_DangerZone.is_in_danger(sor_x, sor_y):
		_pass_next_turn = true
	elif _is_in_swamp(sor_x, sor_y):
		_step_counter += 1
		if _step_counter >= _new_FrogData.SINK_IN_MUD:
			_pass_next_turn = true
			_step_counter = 0
	.move()


func attack() -> void:
	_step_counter = 0
	_ref_CountDown.add_count(_new_FrogData.RESTORE_TURN)
	if not SHOW_FULL_MAP:
		_frog_sprite.resize(0)
	.attack()


func wait() -> void:
	if _ref_DangerZone.is_in_danger(_source_position[0], _source_position[1]):
		return
	_set_pc_state(_new_ObjectStateTag.PASSIVE)
	.wait()


func reset_state() -> void:
	_set_pc_state(_new_ObjectStateTag.DEFAULT)
	.reset_state()


func switch_sprite() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var x: int = _source_position[0]
	var y: int = _source_position[1]

	if _ref_DangerZone.is_in_danger(x, y):
		_ref_SwitchSprite.switch_sprite(pc, _new_SpriteTypeTag.ACTIVE)
	elif _is_in_swamp(x, y):
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


func _is_checkmate() -> bool:
	var x: int = _source_position[0]
	var y: int = _source_position[1]
	var neighbor: Array = _new_CoordCalculator.get_neighbor(x, y, 1)

	if _ref_DangerZone.is_in_danger(x, y):
		for i in neighbor:
			if not (_ref_DangerZone.is_in_danger(i[0], i[1]) \
					or _ref_DungeonBoard.has_sprite(
							_new_MainGroupTag.ACTOR, i[0], i[1])):
				return false
		return true
	return false
