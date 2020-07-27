extends "res://library/pc_action/PCActionTemplate.gd"


var _new_KnightData := preload("res://library/npc_data/KnightData.gd").new()


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func attack() -> void:
	var npc: Sprite = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.ACTOR,
			_target_position[0], _target_position[1])

	if _ref_ObjectData.verify_state(npc, _new_ObjectStateTag.DEFAULT):
		end_turn = false
	elif _ref_ObjectData.verify_state(npc, _new_ObjectStateTag.ACTIVE):
		end_turn = _roll()
	elif _ref_ObjectData.verify_state(npc, _new_ObjectStateTag.PASSIVE):
		if npc.is_in_group(_new_SubGroupTag.KNIGHT_BOSS):
			_hit_boss(npc)
		else:
			_hit_knight()
		end_turn = true
	else:
		end_turn = false


func _hit_knight() -> void:
	_ref_RemoveObject.remove(_new_MainGroupTag.ACTOR,
			_target_position[0], _target_position[1])


func _hit_boss(boss: Sprite) -> void:
	var teleport: Array = [-1, -1]

	if _ref_ObjectData.get_hit_point(boss) < _new_KnightData.MAX_BOSS_HP:
		_ref_ObjectData.add_hit_point(boss, 1)

		while _is_occupied(teleport[0], teleport[1]):
			teleport = _get_new_position()

		_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR,
				_target_position, teleport)
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
			_source_position, roll_over)
	return true


func _get_new_position() -> Array:
	return [
		_ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_X),
		_ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y)
	]
