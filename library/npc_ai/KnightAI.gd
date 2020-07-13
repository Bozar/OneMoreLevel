extends "res://library/npc_ai/AITemplate.gd"


var _range: int = 1
var _default_ground_color: String
var _id_to_danger_zone: Dictionary = {}
var _hit_to_sprite: Dictionary


func _init(object_reference: Array).(object_reference) -> void:
	_hit_to_sprite = {
		0: _new_SpriteTypeTag.DEFAULT,
		1: _new_SpriteTypeTag.DEFAULT_2,
		2: _new_SpriteTypeTag.DEFAULT_3,
	}
	_default_ground_color = _new_Palette.get_default_color(
			_new_MainGroupTag.GROUND)


func take_action(actor: Sprite) -> void:
	_set_local_var(actor)

	# Active -> Passive.
	if _ref_ObjectData.verify_state(_self, _new_ObjectStateTag.ACTIVE):
		_attack()
	# Passive -> Default.
	elif _ref_ObjectData.verify_state(_self, _new_ObjectStateTag.PASSIVE):
		_recover()
	# Default -> Active.
	elif _new_CoordCalculator.is_inside_range(_pc_pos, _self_pos, _range):
		_alert()
	# Approach.
	# else:
	# 	print("Approach")


func _attack() -> void:
	var id: int = _self.get_instance_id()
	var danger_zone: Array = _id_to_danger_zone[id]

	_ref_ObjectData.set_state(_self, _new_ObjectStateTag.PASSIVE)
	_ref_SwitchSprite.switch_sprite(_self, _new_SpriteTypeTag.PASSIVE)

	_switch_ground(danger_zone, false)
	var __ = _id_to_danger_zone.erase(id)


func _recover() -> void:
	var hit: int = _ref_ObjectData.get_hit_point(_self)
	var new_sprite: String = _new_SpriteTypeTag.DEFAULT

	_ref_ObjectData.set_state(_self, _new_ObjectStateTag.DEFAULT)

	if _self.is_in_group(_new_SubGroupTag.KNIGHT_BOSS) \
			and _hit_to_sprite.has(hit):
		new_sprite = _hit_to_sprite[hit]
	_ref_SwitchSprite.switch_sprite(_self, new_sprite)


func _alert() -> void:
	var id: int = _self.get_instance_id()
	var neighbor: Array = _new_CoordCalculator.get_neighbor(_pc_pos, 1, true)
	var candidate: Array = []
	var danger_zone: Array = []
	var one_grid: Array = []
	var two_grids: Array = []
	var four_grids: Array = []

	_ref_ObjectData.set_state(_self, _new_ObjectStateTag.ACTIVE)
	_ref_SwitchSprite.switch_sprite(_self, _new_SpriteTypeTag.ACTIVE)

	for i in neighbor:
		if (i[0] == _self_pos[0]) and (i[1] == _self_pos[1]):
			continue
		elif _ref_DungeonBoard.has_sprite(
				_new_MainGroupTag.BUILDING, i[0], i[1]):
			continue
		candidate.push_back(i)

	one_grid = [_pc_pos]
	for i in candidate:
		if (i[0] == _self_pos[0]) or (i[1] == _self_pos[1]):
			two_grids.push_back(i)
	four_grids = candidate

	if _self.is_in_group(_new_SubGroupTag.KNIGHT):
		danger_zone = one_grid
	elif _self.is_in_group(_new_SubGroupTag.KNIGHT_CAPTAIN):
		danger_zone = two_grids
	elif _self.is_in_group(_new_SubGroupTag.KNIGHT_BOSS):
		if _ref_ObjectData.get_hit_point(_self) > 0:
			danger_zone = four_grids
		else:
			danger_zone = two_grids

	_id_to_danger_zone[id] = danger_zone
	_switch_ground(danger_zone, true)


func _switch_ground(danger_zone: Array, switch_to_active: bool) -> void:
	var switch_ground: Sprite
	var sprite_type: String
	var sprite_color: String

	for i in danger_zone:
		switch_ground = _ref_DungeonBoard.get_sprite(
				_new_MainGroupTag.GROUND, i[0], i[1])

		if switch_to_active:
			sprite_type = _new_SpriteTypeTag.ACTIVE
			sprite_color = _new_Palette.SHADOW
		else:
			sprite_type = _new_SpriteTypeTag.DEFAULT
			sprite_color = _default_ground_color

		_ref_SwitchSprite.switch_sprite(switch_ground, sprite_type)
		switch_ground.modulate = sprite_color
