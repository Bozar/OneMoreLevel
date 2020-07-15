extends "res://library/npc_ai/AITemplate.gd"


var _range: int = 1
var _max_boss_hp: int = 3
var _default_ground_color: String
var _id_to_danger_zone: Dictionary = {}
var _boss_attack_count: Dictionary = {}
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


func remove_data(actor: Sprite) -> void:
	var id: int = actor.get_instance_id()
	var __

	__ = _id_to_danger_zone.erase(id)
	__ = _boss_attack_count.erase(id)


func _attack() -> void:
	var id: int = _self.get_instance_id()
	var danger_zone: Array = _id_to_danger_zone[id]

	_try_hit_pc(danger_zone)
	_set_danger_zone(danger_zone, false)
	_switch_ground(danger_zone, false)

	if _is_final_boss() and (_boss_attack_count[id] < 1):
		_prepare_second_attack(id)
	else:
		_ref_ObjectData.set_state(_self, _new_ObjectStateTag.PASSIVE)
		_ref_SwitchSprite.switch_sprite(_self, _new_SpriteTypeTag.PASSIVE)


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
	var danger_zone: Array = _get_danger_zone()

	_ref_ObjectData.set_state(_self, _new_ObjectStateTag.ACTIVE)
	_ref_SwitchSprite.switch_sprite(_self, _new_SpriteTypeTag.ACTIVE)

	_id_to_danger_zone[id] = danger_zone
	_set_danger_zone(danger_zone, true)
	_switch_ground(danger_zone, true)

	# if _self.is_in_group(_new_SubGroupTag.KNIGHT_BOSS) \
	# 		and _ref_ObjectData.get_hit_point(_self) < _max_boss_hp:
	# 	_ref_ObjectData.add_hit_point(_self, 1)

	if _is_final_boss():
		_boss_attack_count[id] = 0


func _switch_ground(danger_zone: Array, switch_to_active: bool) -> void:
	var ground_sprite: Sprite
	var sprite_type: String
	var sprite_color: String

	for i in danger_zone:
		ground_sprite= _ref_DungeonBoard.get_sprite(
				_new_MainGroupTag.GROUND, i[0], i[1])

		if switch_to_active:
			sprite_type = _new_SpriteTypeTag.ACTIVE
			sprite_color = _new_Palette.SHADOW
		else:
			sprite_type = _new_SpriteTypeTag.DEFAULT
			sprite_color = _default_ground_color

		_ref_SwitchSprite.switch_sprite(ground_sprite, sprite_type)
		ground_sprite.modulate = sprite_color


func _get_danger_zone() -> Array:
	var neighbor: Array = _new_CoordCalculator.get_neighbor(_pc_pos, 1, true)
	var candidate: Array = []
	var one_grid: Array = []
	var two_grids: Array = []
	var four_grids: Array = []
	var danger_zone: Array

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

	return danger_zone


func _is_final_boss() -> bool:
	return _self.is_in_group(_new_SubGroupTag.KNIGHT_BOSS) \
			and (_ref_ObjectData.get_hit_point(_self) == _max_boss_hp)


func _prepare_second_attack(id: int) -> void:
	var danger_zone: Array

	_boss_attack_count[id] += 1

	if _new_CoordCalculator.is_inside_range(_pc_pos, _self_pos, _range):
		danger_zone = _get_danger_zone()
		_id_to_danger_zone[id] = danger_zone
		_set_danger_zone(danger_zone, true)
		_switch_ground(danger_zone, true)


func _set_danger_zone(danger_zone: Array, is_dangerous: bool) -> void:
	for i in danger_zone:
		_ref_DangerZone.set_danger_zone(i[0], i[1], is_dangerous)


func _try_hit_pc(danger_zone: Array) -> void:
	for i in danger_zone:
		if (_pc_pos[0] == i[0]) and (_pc_pos[1] == i[1]):
			print("pc is dead")
