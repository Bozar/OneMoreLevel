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
	pass


func set_source_position() -> void:
	var ground: Sprite

	.set_source_position()
	ground = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.GROUND,
			_source_position[0], _source_position[1])
	_move_diagonally = not _ref_ObjectData.verify_state(ground,
			_new_ObjectStateTag.ACTIVE)
	# _move_diagonally = _ref_ObjectData.verify_state(ground,
	# 		_new_ObjectStateTag.ACTIVE)


func set_target_position(direction: String) -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if _move_diagonally:
		if _count_input == NO_INPUT:
			.set_target_position(direction)
			_ref_SwitchSprite.switch_sprite(pc, INPUT_TO_SPRITE[direction])
			_count_input += 1
		elif _count_input == INPUT_ONCE:
			_set_diagonal_position(direction)
			_ref_SwitchSprite.switch_sprite(pc, _new_SpriteTypeTag.DEFAULT)
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


func interact_with_building() -> void:
	if _move_diagonally:
		_count_input = NO_INPUT


func move() -> void:
	if _move_diagonally:
		if _count_input == INPUT_TWICE:
			if (_source_position[0] != _target_position[0]) \
					and (_source_position[1] != _target_position[1]):
				.move()
				# Try hit NPC.
			_count_input = NO_INPUT
	else:
		.move()
		# Try hit NPC.


func wait() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if _move_diagonally:
		if _count_input > NO_INPUT:
			_ref_SwitchSprite.switch_sprite(pc, _new_SpriteTypeTag.DEFAULT)
			_count_input = NO_INPUT
		else:
			.wait()
	else:
		.wait()


func _set_diagonal_position(direction: String) -> void:
	var save_source_position: Array

	save_source_position = _source_position
	_source_position = _target_position
	.set_target_position(direction)
	_source_position = save_source_position
