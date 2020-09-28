extends "res://library/npc_ai/AITemplate.gd"


var _new_MirrorData := preload("res://library/npc_data/MirrorData.gd").new()


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action(actor: Sprite) -> void:
	if _ref_ObjectData.verify_state(actor, _new_ObjectStateTag.PASSIVE):
		return

	_set_local_var(actor)

	if _new_CoordCalculator.is_inside_range(
			_self_pos[0], _self_pos[1], _pc_pos[0], _pc_pos[1],
			_new_MirrorData.ATTACK_RANGE):
		_attack()
	elif _new_CoordCalculator.is_inside_range(
			_self_pos[0], _self_pos[1], _pc_pos[0], _pc_pos[1],
			_new_MirrorData.PHANTOM_SIGHT):
		_approach_pc()


func _attack() -> void:
	return
