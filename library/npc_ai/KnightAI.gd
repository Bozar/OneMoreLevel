extends "res://library/npc_ai/AITemplate.gd"


var _attack_range: int = 1


func take_action(pc: Sprite, actor: Sprite, node_ref: Array) -> void:
	var pc_pos: Array = _new_ConvertCoord.vector_to_array(pc.position)
	var self_pos: Array = _new_ConvertCoord.vector_to_array(actor.position)

	_ref_ObjectData = node_ref[0]
	_ref_SwitchSprite = node_ref[1]

	if _ref_ObjectData.verify_status(actor, _new_ObjectStatusTag.ACTIVE):
		print(pc_pos[0] - self_pos[0])
		print("alert -> attack")
		_ref_ObjectData.set_status(actor, _new_ObjectStatusTag.PASSIVE)
		_ref_SwitchSprite.switch_sprite(actor, _new_SpriteTypeTag.PASSIVE)
	elif _ref_ObjectData.verify_status(actor, _new_ObjectStatusTag.PASSIVE):
		print(pc_pos[0] - self_pos[0])
		print("attacked -> normal")
		_ref_ObjectData.set_status(actor, _new_ObjectStatusTag.DEFAULT)
		_ref_SwitchSprite.switch_sprite(actor, _new_SpriteTypeTag.DEFAULT)
	elif _new_CoordCalculator.is_inside_range(pc_pos, self_pos,	_attack_range):
		print(pc_pos[0] - self_pos[0])
		print("normal -> alert")
		_ref_ObjectData.set_status(actor, _new_ObjectStatusTag.ACTIVE)
		_ref_SwitchSprite.switch_sprite(actor, _new_SpriteTypeTag.ACTIVE)
	# else:
	# 	print("Approach")
