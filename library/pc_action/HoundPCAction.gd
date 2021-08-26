extends Game_PCActionTemplate


const NO_INPUT: int = 0
const INPUT_ONCE: int = 1
const INPUT_TWICE: int = 2

var _move_diagonally: bool
var _count_input: int = NO_INPUT


func _init(parent_node: Node2D).(parent_node) -> void:
	_fov_render_range = Game_HoundData.PC_SIGHT


func switch_sprite() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var pc_pos: Array = Game_ConvertCoord.vector_to_array(pc.position)
	var ground: Sprite = _ref_DungeonBoard.get_ground(pc_pos[0], pc_pos[1])
	var new_sprite_type: String

	if _ground_is_active(pc_pos[0], pc_pos[1]):
		if _ref_ObjectData.get_hit_point(ground) == 0:
			new_sprite_type = Game_SpriteTypeTag.ACTIVE_1
		else:
			new_sprite_type = Game_SpriteTypeTag.ACTIVE
	else:
		new_sprite_type = Game_SpriteTypeTag.DEFAULT
	_ref_SwitchSprite.switch_sprite(pc, new_sprite_type)


func set_source_position() -> void:
	.set_source_position()
	_move_diagonally = _ground_is_active(
			_source_position[0], _source_position[1])


func set_target_position(direction: String) -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if _move_diagonally:
		if _count_input == NO_INPUT:
			.set_target_position(direction)
			_ref_SwitchSprite.switch_sprite(pc,
					Game_InputTag.INPUT_TO_SPRITE[direction])
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
				_reset_input_state()
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
		_reset_input_state()


func interact_with_building() -> void:
	if _move_diagonally:
		_reset_input_state()


func move() -> void:
	if _move_diagonally:
		if _count_input == INPUT_TWICE:
			if (_source_position[0] != _target_position[0]) \
					and (_source_position[1] != _target_position[1]) \
					and _ground_is_active(
							_target_position[0], _target_position[1]):
				.move()
				_restore_in_cage()
				_try_attack(_move_diagonally)
			_reset_input_state()
	else:
		if not _ground_is_active(_target_position[0], _target_position[1]):
			.move()
			_restore_in_cage()
			_try_attack(_move_diagonally)


func wait() -> void:
	if _move_diagonally:
		if _count_input > NO_INPUT:
			_reset_input_state()
		else:
			.wait()
			_restore_in_cage()
	else:
		.wait()
		_restore_in_cage()


func _is_checkmate() -> bool:
	var neighbor: Array

	if _move_diagonally:
		return false

	neighbor = Game_CoordCalculator.get_neighbor(
			_source_position[0], _source_position[1], 1)
	for i in neighbor:
		if not _ref_DungeonBoard.has_building(i[0], i[1]):
			return false
	return true


func _set_diagonal_position(direction: String) -> void:
	var save_source: Array = _source_position

	_source_position = _target_position
	.set_target_position(direction)
	_source_position = save_source


func _block_line_of_sight(x: int, y: int, _opt_arg: Array) -> bool:
	# Building.
	if _ref_DungeonBoard.has_building(x, y):
		return true
	# Fog.
	elif _ground_is_active(x, y) != _move_diagonally:
		return true
	# Actor.
	else:
		return _ref_DungeonBoard.has_actor(x, y)


func _get_hit_position(hit_diagonally: bool) -> Array:
	var shift_x: int = _target_position[0] - _source_position[0]
	var shift_y: int = _target_position[1] - _source_position[1]
	var mirror: Game_CoordCalculator.MirrorCoord

	if hit_diagonally:
		if shift_x * shift_y > 0:
			mirror = Game_CoordCalculator.get_mirror_image(
					_source_position[0], _source_position[1],
					_source_position[0], _target_position[1])
			return [mirror.x, mirror.y]
		else:
			mirror = Game_CoordCalculator.get_mirror_image(
					_source_position[0], _source_position[1],
					_target_position[0], _source_position[1])
			return [mirror.x, mirror.y]
	else:
		if shift_y != 0:
			shift_y = -shift_y
		return [shift_y + _target_position[0], shift_x + _target_position[1]]


func _can_hit_target(x: int, y: int, hit_diagonally: bool) -> bool:
	var actor: Sprite

	if not (Game_CoordCalculator.is_inside_dungeon(x, y) \
			and _ref_DungeonBoard.has_actor(x, y)):
		return false

	if _ground_is_active(x, y) == hit_diagonally:
		actor = _ref_DungeonBoard.get_actor(x, y)
		if actor.is_in_group(Game_SubTag.HOUND_BOSS):
			return hit_diagonally
		return true
	return false


func _try_set_and_get_boss_hit_point(x: int, y: int) -> int:
	var actor: Sprite = _ref_DungeonBoard.get_actor(x, y)

	if actor.is_in_group(Game_SubTag.HOUND_BOSS):
		_ref_ObjectData.add_hit_point(actor, 1)
		return _ref_ObjectData.get_hit_point(actor)
	return 0


func _try_attack(attack_diagonally: bool) -> void:
	var hit_pos: Array
	var hit_point: int

	hit_pos = _get_hit_position(attack_diagonally)
	if not _can_hit_target(hit_pos[0], hit_pos[1], attack_diagonally):
		return

	_try_hit_phantom(hit_pos[0], hit_pos[1])
	hit_point = _try_set_and_get_boss_hit_point(hit_pos[0], hit_pos[1])
	_ref_RemoveObject.remove_actor(hit_pos[0], hit_pos[1])

	if hit_point == Game_HoundData.MAX_BOSS_HIT_POINT:
		_ref_EndGame.player_win()
	_ref_CountDown.add_count(Game_HoundData.RESTORE_TURN)


func _reset_input_state() -> void:
	_count_input = NO_INPUT
	switch_sprite()


func _restore_in_cage() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var pos: Array = Game_ConvertCoord.vector_to_array(pc.position)
	var neighbor: Array = Game_CoordCalculator.get_neighbor(pos[0], pos[1], 1)
	var is_surrounded: bool = true

	for i in neighbor:
		if not _ref_DungeonBoard.has_building(i[0], i[1]):
			is_surrounded = false
			break
	if is_surrounded:
		_ref_CountDown.add_count(Game_HoundData.RESTORE_TURN_IN_CAGE)


func _try_hit_phantom(x: int, y: int) -> void:
	var actor: Sprite = _ref_DungeonBoard.get_actor(x, y)
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if actor.is_in_group(Game_SubTag.PHANTOM):
		_ref_ObjectData.set_hit_point(pc, 0)


func _ground_is_active(x: int, y: int) -> bool:
	var ground: Sprite = _ref_DungeonBoard.get_ground(x, y)
	return _ref_ObjectData.verify_state(ground, Game_ObjectStateTag.ACTIVE)
