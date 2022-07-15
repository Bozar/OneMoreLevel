extends Game_PCActionTemplate


const ONE_TURN := 1
const NO_INPUT := 0
const INPUT_ONCE := 1
const INPUT_TWICE := 2

var _move_diagonally: bool
var _count_input := NO_INPUT


func _init(parent_node: Node2D).(parent_node) -> void:
	_fov_render_range = Game_HoundData.PC_SIGHT


func switch_sprite() -> void:
	_set_pc_sprite()
	_set_phantom_sprite()


func set_source_position() -> void:
	.set_source_position()
	_move_diagonally = _ground_is_active(_source_position)


func set_target_position(direction: String) -> void:
	var pc := _ref_DungeonBoard.get_pc()
	var new_type: String

	if _move_diagonally:
		if _count_input == NO_INPUT:
			.set_target_position(direction)
			new_type = Game_InputTag.INPUT_TO_SPRITE[direction]
			_ref_SwitchSprite.set_sprite(pc, new_type)
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
			if (_source_position.x != _target_position.x) \
					and (_source_position.y != _target_position.y) \
					and _ground_is_active(_target_position):
				.move()
				_restore_in_cage()
				_try_attack(_move_diagonally)
			_reset_input_state()
	else:
		if not _ground_is_active(_target_position):
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


func reset_state() -> void:
	.reset_state()
	_ref_CountDown.add_count(ONE_TURN)


func _is_checkmate() -> bool:
	var neighbor: Array

	if _move_diagonally:
		return false

	neighbor = Game_CoordCalculator.get_neighbor(_source_position, 1)
	for i in neighbor:
		if not _ref_DungeonBoard.has_building(i):
			return false
	return true


func _set_diagonal_position(direction: String) -> void:
	var save_source: Game_IntCoord = _source_position

	_source_position = _target_position
	.set_target_position(direction)
	_source_position = save_source


func _block_line_of_sight(x: int, y: int, _opt_arg: Array) -> bool:
	var pos := Game_IntCoord.new(x, y)

	# Building.
	if _ref_DungeonBoard.has_building(pos):
		return true
	# Fog.
	elif _ground_is_active(pos) != _move_diagonally:
		return true
	# Actor.
	else:
		return _ref_DungeonBoard.has_actor(pos)


func _get_hit_position(hit_diagonally: bool) -> Game_IntCoord:
	var shift_x: int = _target_position.x - _source_position.x
	var shift_y: int = _target_position.y - _source_position.y
	var coord: Game_IntCoord

	if hit_diagonally:
		if shift_x * shift_y > 0:
			coord = Game_CoordCalculator.get_mirror_image_xy(
					_source_position.x, _source_position.y,
					_source_position.x, _target_position.y)
		else:
			coord = Game_CoordCalculator.get_mirror_image_xy(
					_source_position.x, _source_position.y,
					_target_position.x, _source_position.y)
		return coord
	else:
		if shift_y != 0:
			shift_y = -shift_y
		return Game_IntCoord.new(
				shift_y + _target_position.x,
				shift_x + _target_position.y
		)


func _can_hit_target(coord: Game_IntCoord, hit_diagonally: bool) -> bool:
	if not Game_CoordCalculator.is_inside_dungeon(coord.x, coord.y):
		return false
	elif not _ref_DungeonBoard.has_actor(coord):
		return false

	if _ground_is_active(coord) == hit_diagonally:
		if _ref_DungeonBoard.has_sprite_with_sub_tag(Game_MainTag.ACTOR,
				Game_SubTag.HOUND_BOSS, coord):
			return hit_diagonally
		return true
	return false


func _try_attack(attack_diagonally: bool) -> void:
	var hit_pos: Game_IntCoord
	var hit_actor: Sprite
	var pc := _ref_DungeonBoard.get_pc()
	var remove_this := true
	var win := false

	hit_pos = _get_hit_position(attack_diagonally)
	if not _can_hit_target(hit_pos, attack_diagonally):
		return

	_ref_CountDown.subtract_count(ONE_TURN)
	hit_actor = _ref_DungeonBoard.get_actor(hit_pos)
	if hit_actor.is_in_group(Game_SubTag.PHANTOM):
		_ref_ObjectData.set_hit_point(pc, 0)
	elif hit_actor.is_in_group(Game_SubTag.HOUND_BOSS):
		_ref_ObjectData.subtract_hit_point(hit_actor,
				Game_HoundData.PC_HIT_BOSS)
		remove_this = _ref_ObjectData.get_hit_point(hit_actor) < 1
		win = remove_this

	if remove_this:
		_ref_RemoveObject.remove_actor(hit_pos)
	if win:
		_ref_EndGame.player_win()


func _reset_input_state() -> void:
	_count_input = NO_INPUT
	switch_sprite()


func _restore_in_cage() -> void:
	var pos := _ref_DungeonBoard.get_pc_coord()
	var neighbor := Game_CoordCalculator.get_neighbor(pos, 1)
	var is_surrounded := true
	var phantoms := _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.PHANTOM)
	var pc := _ref_DungeonBoard.get_pc()
	var hp := _ref_ObjectData.get_hit_point(pc)

	for i in neighbor:
		if not _ref_DungeonBoard.has_building(i):
			is_surrounded = false
			break
	if is_surrounded:
		if phantoms.size() > 0:
			hp -= Game_HoundData.SUBTRACT_HIT_POINT_IN_CAGE
			hp = max(hp, 0) as int
			_ref_ObjectData.set_hit_point(pc, hp)


func _ground_is_active(coord: Game_IntCoord) -> bool:
	var ground := _ref_DungeonBoard.get_ground(coord)
	return _ref_ObjectData.verify_state(ground, Game_StateTag.ACTIVE)


func _set_pc_sprite() -> void:
	var pc := _ref_DungeonBoard.get_pc()
	var pc_pos := _ref_DungeonBoard.get_pc_coord()
	var ground := _ref_DungeonBoard.get_ground(pc_pos)
	var new_sprite_type: String

	if _ground_is_active(pc_pos):
		if _ref_ObjectData.get_hit_point(ground) == 0:
			new_sprite_type = Game_SpriteTypeTag.ACTIVE_1
		else:
			new_sprite_type = Game_SpriteTypeTag.ACTIVE
	else:
		new_sprite_type = Game_SpriteTypeTag.DEFAULT
	_ref_SwitchSprite.set_sprite(pc, new_sprite_type)


func _set_phantom_sprite() -> void:
	var pc := _ref_DungeonBoard.get_pc()
	var hp := _ref_ObjectData.get_hit_point(pc)
	var new_sprite_type: String
	var phantoms := _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.PHANTOM)

	if phantoms.size() < 1:
		return

	new_sprite_type = Game_SpriteTypeTag.convert_digit_to_tag(
			Game_HoundData.MAX_PC_HIT_POINT - hp)
	_ref_SwitchSprite.set_sprite(phantoms[0], new_sprite_type)
