extends "res://library/pc_action/PCActionTemplate.gd"


const HALF_WIDTH: int = 1

var _new_KnightData := preload("res://library/npc_data/KnightData.gd").new()
var _new_ShadowCastFOV := preload("res://library/ShadowCastFOV.gd").new()


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func render_fov() -> void:
	if SHOW_FULL_MAP:
		return

	_new_ShadowCastFOV.set_field_of_view(
			_source_position[0], _source_position[1],
			_new_KnightData.RENDER_RANGE,
			self, "_block_ray", [])

	for x in range(_new_DungeonSize.MAX_X):
		for y in range(_new_DungeonSize.MAX_Y):
			for i in _new_MainGroupTag.DUNGEON_OBJECT:
				_set_sprite_color(x, y, i, "",
				_new_ShadowCastFOV, "is_in_sight")


func attack() -> void:
	var npc: Sprite = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.ACTOR,
			_target_position[0], _target_position[1])

	if _ref_ObjectData.verify_state(npc, _new_ObjectStateTag.DEFAULT):
		end_turn = false
	elif _ref_ObjectData.verify_state(npc, _new_ObjectStateTag.ACTIVE):
		end_turn = _roll()
	elif _ref_ObjectData.verify_state(npc, _new_ObjectStateTag.PASSIVE):
		if _ref_DangerZone.is_in_danger(
				_source_position[0], _source_position[1]):
			end_turn = false
			return
		if npc.is_in_group(_new_SubGroupTag.KNIGHT_BOSS):
			_hit_boss(npc)
		else:
			_hit_knight()
		_ref_CountDown.add_count(_new_KnightData.RESTORE_TURN)
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
		elif _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR,
				i[0], i[1]):
			actor = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.ACTOR,
					i[0], i[1])
			if _ref_ObjectData.verify_state(actor,
					_new_ObjectStateTag.ACTIVE):
				mirror = _new_CoordCalculator.get_mirror_image(
						x, y, i[0], i[1])
				if (mirror.size() >= 2) \
						and (not _is_occupied(mirror[0], mirror[1])):
					return false
	return true


func _hit_knight() -> void:
	_ref_RemoveObject.remove(_new_MainGroupTag.ACTOR,
			_target_position[0], _target_position[1])


func _hit_boss(boss: Sprite) -> void:
	var teleport: Array = [-1, -1]
	var is_occupied: bool = true
	var is_too_close: bool = true

	if _ref_ObjectData.get_hit_point(boss) < _new_KnightData.MAX_BOSS_HP:
		_ref_ObjectData.add_hit_point(boss, 1)

		while is_occupied or is_too_close:
			teleport = _get_new_position()
			is_occupied = _is_occupied(teleport[0], teleport[1])
			is_too_close = _new_CoordCalculator.is_inside_range(
					teleport[0], teleport[1],
					_source_position[0], _source_position[1],
					_new_KnightData.ELITE_SIGHT)

		_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR,
				_target_position[0], _target_position[1],
				 teleport[0], teleport[1])
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

	_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR,
			_source_position[0], _source_position[1],
			roll_over[0], roll_over[1])
	return true


func _get_new_position() -> Array:
	return [
		_ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_X),
		_ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y)
	]


func _block_ray(x: int, y: int, _opt_arg: Array) -> bool:
	return _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING, x, y)
