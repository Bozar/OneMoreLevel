extends "res://library/npc_ai/AITemplate.gd"


var _attack_range: int = 1


func take_action(pc: Sprite, actor: Sprite, node_ref: AIFuncParam) -> void:
	_set_local_var(pc, actor, node_ref)

	# Active -> Passive.
	if _node.ref_ObjectData.verify_state(
			_self, _new_ObjectStateTag.ACTIVE):
		_attack()
	# Passive -> Default.
	elif _node.ref_ObjectData.verify_state(
			_self, _new_ObjectStateTag.PASSIVE):
		_recover()
	# Default -> Active.
	elif _new_CoordCalculator.is_inside_range(
			_pc_pos, _self_pos, _attack_range):
		_alert()
	# Approach.
	# else:
	# 	print("Approach")


func _attack() -> void:
	_node.ref_ObjectData.set_state(
			_self, _new_ObjectStateTag.PASSIVE)
	_node.ref_SwitchSprite.switch_sprite(
			_self, _new_SpriteTypeTag.PASSIVE)


func _recover() -> void:
	_node.ref_ObjectData.set_state(
			_self, _new_ObjectStateTag.DEFAULT)
	_node.ref_SwitchSprite.switch_sprite(
			_self, _new_SpriteTypeTag.DEFAULT)


func _alert() -> void:
	_node.ref_ObjectData.set_state(
			_self, _new_ObjectStateTag.ACTIVE)
	_node.ref_SwitchSprite.switch_sprite(
			_self, _new_SpriteTypeTag.ACTIVE)
