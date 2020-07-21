extends "res://library/pc_action/PCActionTemplate.gd"


var _max_boss_hp: int = 2


func _init(object_reference: Array).(object_reference) -> void:
	pass


func attack() -> void:
	var npc: Sprite = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.ACTOR,
			_target_position[0], _target_position[1])

	if _ref_ObjectData.verify_state(npc, _new_ObjectStateTag.DEFAULT):
		end_turn = false
	elif _ref_ObjectData.verify_state(npc, _new_ObjectStateTag.ACTIVE):
		_roll()
		end_turn = true
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
	if _ref_ObjectData.get_hit_point(boss) < _max_boss_hp:
		_ref_ObjectData.add_hit_point(boss, 1)
	else:
		_hit_knight()


func _roll() -> void:
	_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR,
			_source_position, [0, 0])
