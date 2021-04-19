extends "res://library/pc_action/PCActionTemplate.gd"


const NO_INPUT: int = 0
const INPUT_ONCE: int = 1
const INPUT_TWICE: int = 2

var _new_HoundData := preload("res://library/npc_data/HoundData.gd").new()

var _move_diagonally: bool
var _count_input: int = NO_INPUT


func _init(parent_node: Node2D).(parent_node) -> void:
	_fov_render_range = _new_HoundData.PC_SIGHT


func switch_sprite() -> void:
	_switch_pc_sprite(_move_diagonally)


func set_source_position() -> void:
	var ground: Sprite

	.set_source_position()
	ground = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.GROUND,
			_source_position[0], _source_position[1])
	_move_diagonally = _ref_ObjectData.verify_state(ground,
			_new_ObjectStateTag.ACTIVE)


func set_target_position(direction: String) -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if _move_diagonally:
		if _count_input == NO_INPUT:
			.set_target_position(direction)
			_ref_SwitchSprite.switch_sprite(pc, INPUT_TO_SPRITE[direction])
			_count_input += 1
		elif _count_input == INPUT_ONCE:
			_set_diagonal_position(direction)
			_count_input += 1
	else:
		.set_target_position(direction)


func is_inside_dungeon() -> bool:
	if _move_diagonally:
		if _count_input == INPUT_TWICE:
			if .is_inside_dungeon():
				return true
			else:
				_count_input = NO_INPUT
				_switch_pc_sprite(true)
				return false
		else:
			return false
	else:
		return .is_inside_dungeon()


func is_npc() -> bool:
	if _move_diagonally:
		if _count_input == INPUT_TWICE:
			return .is_npc()
		else:
			return false
	else:
		return .is_npc()


func is_building() -> bool:
	if _move_diagonally:
		if _count_input == INPUT_TWICE:
			return .is_building()
		else:
			return false
	else:
		return .is_building()


func is_trap() -> bool:
	return false


func attack() -> void:
	if _move_diagonally:
		_count_input = NO_INPUT
		_switch_pc_sprite(true)


func interact_with_building() -> void:
	if _move_diagonally:
		_count_input = NO_INPUT
		_switch_pc_sprite(true)


func move() -> void:
	var ground: Sprite = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.GROUND,
			_target_position[0], _target_position[1])

	if _move_diagonally:
		if _count_input == INPUT_TWICE:
			if (_source_position[0] != _target_position[0]) \
					and (_source_position[1] != _target_position[1]) \
					and _ref_ObjectData.verify_state(ground,
							_new_ObjectStateTag.ACTIVE):
				.move()
				_attack(_move_diagonally)
			_count_input = NO_INPUT
			_switch_pc_sprite(true)
	else:
		if _ref_ObjectData.verify_state(ground, _new_ObjectStateTag.DEFAULT):
			.move()
			_attack(_move_diagonally)


func wait() -> void:
	if _move_diagonally:
		if _count_input > NO_INPUT:
			_count_input = NO_INPUT
			_switch_pc_sprite(true)
		else:
			.wait()
	else:
		.wait()


func _is_checkmate() -> bool:
	var neighbor: Array

	if _move_diagonally:
		return false

	neighbor = _new_CoordCalculator.get_neighbor(
			_source_position[0], _source_position[1], 1)
	for i in neighbor:
		if not _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING,
				i[0], i[1]):
			return false
	return true


func _set_diagonal_position(direction: String) -> void:
	var save_source_position: Array

	save_source_position = _source_position
	_source_position = _target_position
	.set_target_position(direction)
	_source_position = save_source_position


func _block_line_of_sight(x: int, y: int, _opt_arg: Array) -> bool:
	var ground: Sprite = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.GROUND,
			x, y)

	# Building.
	if ground == null:
		return true
	# Fog.
	elif _ref_ObjectData.verify_state(ground, _new_ObjectStateTag.ACTIVE) \
			!= _move_diagonally:
		return true
	# Actor.
	else:
		return _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR, x, y)


func _switch_pc_sprite(is_active: bool) -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if is_active:
		_ref_SwitchSprite.switch_sprite(pc, _new_SpriteTypeTag.ACTIVE)
	else:
		_ref_SwitchSprite.switch_sprite(pc, _new_SpriteTypeTag.DEFAULT)


func _get_hit_position(hit_diagonally: bool) -> Array:
	var shift_x: int = _target_position[0] - _source_position[0]
	var shift_y: int = _target_position[1] - _source_position[1]

	if hit_diagonally:
		if shift_x * shift_y > 0:
			return _new_CoordCalculator.get_mirror_image(
					_source_position[0], _source_position[1],
					_source_position[0], _target_position[1], true)
		else:
			return _new_CoordCalculator.get_mirror_image(
					_source_position[0], _source_position[1],
					_target_position[0], _source_position[1], true)
	else:
		if shift_y != 0:
			shift_y = -shift_y
		return [shift_y + _target_position[0], shift_x + _target_position[1]]


func _can_hit_target(x: int, y: int, hit_diagonally: bool) -> bool:
	var ground: Sprite
	var actor: Sprite

	if not (_new_CoordCalculator.is_inside_dungeon(x, y) \
			and _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR, x, y)):
		return false

	ground = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.GROUND, x, y)
	if _ref_ObjectData.verify_state(ground, _new_ObjectStateTag.ACTIVE) \
			== hit_diagonally:
		actor = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.ACTOR, x, y)
		if actor.is_in_group(_new_SubGroupTag.HOUND_BOSS):
			return hit_diagonally
		return true
	return false


func _try_set_and_get_boss_hit_point(x: int, y: int) -> int:
	var actor: Sprite

	actor = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.ACTOR, x, y)
	if actor.is_in_group(_new_SubGroupTag.HOUND_BOSS):
		_ref_ObjectData.add_hit_point(actor, 1)
		return _ref_ObjectData.get_hit_point(actor)
	return 0


func _attack(attack_diagonally: bool) -> void:
	var hit_pos: Array

	hit_pos = _get_hit_position(attack_diagonally)
	if _can_hit_target(hit_pos[0], hit_pos[1], attack_diagonally):
		if attack_diagonally:
			if _try_set_and_get_boss_hit_point(hit_pos[0], hit_pos[1]) \
					== _new_HoundData.MAX_BOSS_HIT_POINT:
				_ref_EndGame.player_win()
		_ref_RemoveObject.remove(_new_MainGroupTag.ACTOR,
				hit_pos[0], hit_pos[1])
		_ref_CountDown.add_count(_new_HoundData.RESTORE_TURN)
