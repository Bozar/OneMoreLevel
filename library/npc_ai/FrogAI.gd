extends "res://library/npc_ai/AITemplate.gd"


var _new_FrogData := preload("res://library/npc_data/FrogData.gd").new()

var _id_to_danger_zone: Dictionary = {}


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action() -> void:
	var id: int = _self.get_instance_id()

	if _id_to_danger_zone.has(id):
		_attack(id)
	elif _pc_wait():
		_idle()
	elif _is_in_attack_range():
		_grapple(id)
	elif _is_in_sight_range():
		_approach()
	else:
		_idle()


func remove_data(actor: Sprite) -> void:
	var id: int = actor.get_instance_id()
	var __

	if _id_to_danger_zone.has(id):
		_ref_DangerZone.set_danger_zone(
				_id_to_danger_zone[id][0], _id_to_danger_zone[id][1], false)
		__ = _id_to_danger_zone.erase(actor.get_instance_id())


func _attack(id: int) -> void:
	var x: int = _id_to_danger_zone[id][0]
	var y: int = _id_to_danger_zone[id][1]
	var __

	__ = _id_to_danger_zone.erase(id)
	_ref_DangerZone.set_danger_zone(x, y, false)
	_ref_SwitchSprite.switch_sprite(_self, _new_SpriteTypeTag.DEFAULT)

	if _ref_DungeonBoard.has_sprite_with_sub_tag(
			_new_MainGroupTag.ACTOR, _new_SubGroupTag.PC, x, y):
		_ref_EndGame.player_lose()


func _grapple(id: int) -> void:
	_id_to_danger_zone[id] = _pc_pos
	_ref_DangerZone.set_danger_zone(_pc_pos[0], _pc_pos[1], true)
	_ref_SwitchSprite.switch_sprite(_self, _new_SpriteTypeTag.ACTIVE)


func _approach() -> void:
	print(_pc_pos[0])
	print(_pc_pos[1])


func _idle() -> void:
	print("idle")


func _pc_wait() -> bool:
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	return _ref_ObjectData.verify_state(pc, _new_ObjectStateTag.PASSIVE)


func _is_in_attack_range() -> bool:
	return _new_CoordCalculator.is_inside_range(
			_self_pos[0], _self_pos[1], _pc_pos[0], _pc_pos[1],
			_new_FrogData.ATTACK_RANGE)


func _is_in_sight_range() -> bool:
	var sight_range: int = _new_FrogData.SIGHT

	if _self.is_in_group(_new_SubGroupTag.FROG_PRINCESS):
		sight_range = _new_FrogData.PRINCESS_SIGHT

	return _new_CoordCalculator.is_inside_range(
			_self_pos[0], _self_pos[1], _pc_pos[0], _pc_pos[1],
			sight_range)
