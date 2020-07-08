extends "res://library/npc_ai/AITemplate.gd"


var _attack_range: int = 1
var _hit_to_sprite: Dictionary = {
	0: _new_SpriteTypeTag.DEFAULT,
	1: _new_SpriteTypeTag.DEFAULT_2,
	2: _new_SpriteTypeTag.DEFAULT_3,
}


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
	var hit: int = _node.ref_ObjectData.get_hit_point(_self)
	var new_sprite: String = _new_SpriteTypeTag.DEFAULT

	_node.ref_ObjectData.set_state(
			_self, _new_ObjectStateTag.DEFAULT)

	if _self.is_in_group(_new_SubGroupTag.KNIGHT_BOSS) \
			and _hit_to_sprite.has(hit):
		new_sprite = _hit_to_sprite[hit]
	_node.ref_SwitchSprite.switch_sprite(_self, new_sprite)


func _alert() -> void:
	_node.ref_ObjectData.set_state(
			_self, _new_ObjectStateTag.ACTIVE)
	_node.ref_SwitchSprite.switch_sprite(
			_self, _new_SpriteTypeTag.ACTIVE)
