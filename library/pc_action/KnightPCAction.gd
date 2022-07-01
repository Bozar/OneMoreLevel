extends Game_PCActionTemplate


const HALF_WIDTH: int = 1


func _init(parent_node: Node2D).(parent_node) -> void:
	_fov_render_range = Game_KnightData.RENDER_RANGE


func switch_sprite() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if _ref_DangerZone.is_in_danger(_source_position.x, _source_position.y):
		_ref_SwitchSprite.set_sprite(pc, Game_SpriteTypeTag.ACTIVE)
	elif _ref_ObjectData.verify_state(pc, Game_StateTag.PASSIVE):
		_ref_SwitchSprite.set_sprite(pc, Game_SpriteTypeTag.PASSIVE)
	else:
		_ref_SwitchSprite.set_sprite(pc, Game_SpriteTypeTag.DEFAULT)


func attack() -> void:
	var npc: Sprite = _ref_DungeonBoard.get_actor_xy(
			_target_position.x, _target_position.y)
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if _ref_ObjectData.verify_state(npc, Game_StateTag.DEFAULT):
		end_turn = false
	elif _ref_ObjectData.verify_state(npc, Game_StateTag.ACTIVE):
		end_turn = _roll()
	elif _ref_ObjectData.verify_state(npc, Game_StateTag.PASSIVE):
		if _ref_DangerZone.is_in_danger(_source_position.x, _source_position.y):
			end_turn = false
			return
		_ref_ObjectData.set_state(pc, Game_StateTag.DEFAULT)
		if npc.is_in_group(Game_SubTag.KNIGHT_BOSS):
			_hit_boss(npc)
		else:
			_hit_knight()
		_ref_CountDown.add_count(Game_KnightData.RESTORE_TURN)
		end_turn = true
	else:
		end_turn = false


func move() -> void:
	if _ref_DangerZone.is_in_danger(_target_position.x, _target_position.y):
		return
	.move()


func wait() -> void:
	if _ref_DangerZone.is_in_danger(_source_position.x, _source_position.y):
		return
	.wait()


func _is_checkmate() -> bool:
	var x: int = _source_position.x
	var y: int = _source_position.y
	var neighbor: Array = Game_CoordCalculator.get_neighbor_xy(x, y, 1)
	var actor: Sprite
	var coord: Game_IntCoord

	if not _ref_DangerZone.is_in_danger(x, y):
		return false
	for i in neighbor:
		if not (_ref_DangerZone.is_in_danger(i.x, i.y) \
				or _is_occupied(i.x, i.y)):
			return false
		elif _ref_DungeonBoard.has_actor_xy(i.x, i.y):
			actor = _ref_DungeonBoard.get_actor_xy(i.x, i.y)
			if _ref_ObjectData.verify_state(actor, Game_StateTag.ACTIVE):
				coord = Game_CoordCalculator.get_mirror_image_xy(x, y, i.x, i.y)
				if Game_CoordCalculator.is_inside_dungeon(coord.x, coord.y) \
						and (not _is_occupied(coord.x, coord.y)):
					return false
	return true


func _hit_knight() -> void:
	_ref_RemoveObject.remove_actor_xy(_target_position.x, _target_position.y)


func _hit_boss(boss: Sprite) -> void:
	var is_occupied: bool = true
	var is_too_close: bool = true
	var teleport_x: int
	var teleport_y: int

	if _ref_ObjectData.get_hit_point(boss) < Game_KnightData.MAX_BOSS_HP:
		_ref_ObjectData.add_hit_point(boss, 1)

		while is_occupied or is_too_close:
			teleport_x = _ref_RandomNumber.get_x_coord()
			teleport_y = _ref_RandomNumber.get_y_coord()
			is_occupied = _is_occupied(teleport_x, teleport_y)
			is_too_close = Game_CoordCalculator.is_in_range_xy(
					teleport_x, teleport_y,
					_source_position.x, _source_position.y,
					Game_KnightData.ELITE_SIGHT)

		_ref_DungeonBoard.move_actor_xy(_target_position.x, _target_position.y,
				teleport_x, teleport_y)
	else:
		_hit_knight()
		_ref_EndGame.player_win()


func _roll() -> bool:
	var neighbor: Array = Game_CoordCalculator.get_neighbor_xy(
			_target_position.x, _target_position.y, 1)
	var roll_over := Game_IntCoord.new(-1, -1)
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	for i in neighbor:
		if (i.x == _source_position.x) and (i.y == _source_position.y):
			continue
		elif (i.x == _source_position.x) or (i.y == _source_position.y):
			roll_over = i
			break

	if _is_occupied(roll_over.x, roll_over.y):
		return false

	_ref_DungeonBoard.move_actor_xy(_source_position.x, _source_position.y,
			roll_over.x, roll_over.y)
	_ref_ObjectData.set_state(pc, Game_StateTag.PASSIVE)
	return true
