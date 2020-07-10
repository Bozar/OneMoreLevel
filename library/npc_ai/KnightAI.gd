extends "res://library/npc_ai/AITemplate.gd"


var _attack_range: int = 1
var _id_to_danger_zone: Dictionary = {}
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
	var id: int = _self.get_instance_id()
	var danger_zone: Array = _id_to_danger_zone[id]
	var switch_floor: Sprite

	_node.ref_ObjectData.set_state(
			_self, _new_ObjectStateTag.PASSIVE)
	_node.ref_SwitchSprite.switch_sprite(_self, _new_SpriteTypeTag.PASSIVE)

	for i in danger_zone:
		switch_floor = _node.ref_DungeonBoard.get_sprite(
				_new_MainGroupTag.GROUND, i[0], i[1])
		switch_floor.modulate = _new_Palette.get_default_color(
				_new_MainGroupTag.GROUND, _new_SubGroupTag.FLOOR)
		_node.ref_SwitchSprite.switch_sprite(
				switch_floor, _new_SpriteTypeTag.DEFAULT)

	var __ = _id_to_danger_zone.erase(id)


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
	var id: int = _self.get_instance_id()
	var neighbor: Array = _new_CoordCalculator.get_neighbor(_pc_pos, 1, true)
	var candidate: Array = []
	var danger_zone: Array = []
	var switch_floor: Sprite

	_node.ref_ObjectData.set_state(
			_self, _new_ObjectStateTag.ACTIVE)
	_node.ref_SwitchSprite.switch_sprite(_self, _new_SpriteTypeTag.ACTIVE)

	for i in neighbor:
		if (i[0] == _self_pos[0]) and (i[1] == _self_pos[1]):
			continue
		elif _node.ref_DungeonBoard.has_sprite(
				_new_MainGroupTag.BUILDING, i[0], i[1]):
			continue
		candidate.push_back(i)

	if _self.is_in_group(_new_SubGroupTag.KNIGHT):
		danger_zone.push_back(_pc_pos)
	elif _self.is_in_group(_new_SubGroupTag.KNIGHT_CAPTAIN):
		for i in candidate:
			if (i[0] == _self_pos[0]) or (i[1] == _self_pos[1]):
				danger_zone.push_back(i)
	elif _self.is_in_group(_new_SubGroupTag.KNIGHT_BOSS):
		danger_zone = candidate
	_id_to_danger_zone[id] = danger_zone

	for i in danger_zone:
		switch_floor = _node.ref_DungeonBoard.get_sprite(
				_new_MainGroupTag.GROUND, i[0], i[1])
		switch_floor.modulate = _new_Palette.SHADOW
		_node.ref_SwitchSprite.switch_sprite(switch_floor,
				_new_SpriteTypeTag.ACTIVE)
