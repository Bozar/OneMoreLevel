extends Game_PCActionTemplate


const HALF_WIDTH: int = 1


func _init(parent_node: Node2D).(parent_node) -> void:
	_fov_render_range = Game_KnightData.RENDER_RANGE


func attack() -> void:
	var npc: Sprite = _ref_DungeonBoard.get_actor(
			_target_position[0], _target_position[1])

	if _ref_ObjectData.verify_state(npc, Game_ObjectStateTag.DEFAULT):
		end_turn = false
	elif _ref_ObjectData.verify_state(npc, Game_ObjectStateTag.ACTIVE):
		end_turn = _roll()
	elif _ref_ObjectData.verify_state(npc, Game_ObjectStateTag.PASSIVE):
		if _ref_DangerZone.is_in_danger(
				_source_position[0], _source_position[1]):
			end_turn = false
			return
		if npc.is_in_group(Game_SubGroupTag.KNIGHT_BOSS):
			_hit_boss(npc)
		else:
			_hit_knight()
		_ref_CountDown.add_count(Game_KnightData.RESTORE_TURN)
		end_turn = true
	else:
		end_turn = false


func move() -> void:
	if _ref_DangerZone.is_in_danger(_target_position[0], _target_position[1]):
		return
	.move()


func wait() -> void:
	if _ref_DangerZone.is_in_danger(_source_position[0], _source_position[1]):
		return
	.wait()


func _is_checkmate() -> bool:
	var x: int = _source_position[0]
	var y: int = _source_position[1]
	var neighbor: Array = _new_CoordCalculator.get_neighbor(x, y, 1)
	var actor: Sprite
	var mirror: Array

	if not _ref_DangerZone.is_in_danger(x, y):
		return false
	for i in neighbor:
		if not (_ref_DangerZone.is_in_danger(i[0], i[1]) \
				or _is_occupied(i[0], i[1])):
			return false
		elif _ref_DungeonBoard.has_actor(i[0], i[1]):
			actor = _ref_DungeonBoard.get_actor(i[0], i[1])
			if _ref_ObjectData.verify_state(actor, Game_ObjectStateTag.ACTIVE):
				mirror = _new_CoordCalculator.get_mirror_image(
						x, y, i[0], i[1])
				if (mirror.size() >= 2) \
						and (not _is_occupied(mirror[0], mirror[1])):
					return false
	return true


func _hit_knight() -> void:
	_ref_RemoveObject.remove_actor(_target_position[0], _target_position[1])


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
			is_too_close = _new_CoordCalculator.is_inside_range(
					teleport_x, teleport_y,
					_source_position[0], _source_position[1],
					Game_KnightData.ELITE_SIGHT)

		_ref_DungeonBoard.move_sprite(Game_MainGroupTag.ACTOR,
				_target_position[0], _target_position[1],
				teleport_x, teleport_y)
	else:
		_hit_knight()
		_ref_EndGame.player_win()


func _roll() -> bool:
	var neighbor: Array = _new_CoordCalculator.get_neighbor(
			_target_position[0], _target_position[1], 1)
	var roll_over: Array = [-1, -1]

	for i in neighbor:
		if (i[0] == _source_position[0]) and (i[1] == _source_position[1]):
			continue
		elif (i[0] == _source_position[0]) or (i[1] == _source_position[1]):
			roll_over = i
			break

	if _is_occupied(roll_over[0], roll_over[1]):
		return false

	_ref_DungeonBoard.move_sprite(Game_MainGroupTag.ACTOR,
			_source_position[0], _source_position[1],
			roll_over[0], roll_over[1])
	return true
