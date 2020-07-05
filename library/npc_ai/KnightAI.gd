extends "res://library/npc_ai/AITemplate.gd"


var _attack_range: int = 1


func take_action(pc: Sprite, actor: Sprite, status: ObjectStatus) -> void:
	var pc_pos: Array = _new_ConvertCoord.vector_to_array(pc.position)
	var self_pos: Array = _new_ConvertCoord.vector_to_array(actor.position)

	if status.verify_status(actor, _new_ObjectStatusTag.ACTIVE):
		print(pc_pos[0] - self_pos[0])
		print("alert -> attack")
		status.set_status(actor, _new_ObjectStatusTag.PASSIVE)
	elif status.verify_status(actor, _new_ObjectStatusTag.PASSIVE):
		print(pc_pos[0] - self_pos[0])
		print("attacked -> normal")
		status.set_status(actor, _new_ObjectStatusTag.DEFAULT)
	elif _new_CoordCalculator.is_inside_range(pc_pos, self_pos,	_attack_range):
		print(pc_pos[0] - self_pos[0])
		print("normal -> alert")
		status.set_status(actor, _new_ObjectStatusTag.ACTIVE)
	# else:
	# 	print("Approach")
