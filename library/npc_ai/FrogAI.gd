extends "res://library/npc_ai/AITemplate.gd"


var _new_FrogData := preload("res://library/npc_data/FrogData.gd").new()
var _new_ArrayHelper := preload("res://library/ArrayHelper.gd").new()

var _id_to_danger_zone: Dictionary = {}


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action() -> void:
	var id: int = _self.get_instance_id()
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if _id_to_danger_zone.has(id):
		_try_attack(id, pc)
	elif _ref_ObjectData.get_hit_point(_self) > 0:
		_ref_ObjectData.add_hit_point(_self, -1)
	else:
		_reset_hit_point()
		if _can_grapple(pc):
			_grapple(id)
		else:
			_random_walk()


func remove_data(actor: Sprite) -> void:
	var id: int = actor.get_instance_id()
	var __

	if not _id_to_danger_zone.has(id):
		return

	for i in _id_to_danger_zone[id]:
		_set_danger_zone(i[0], i[1], false)
	__ = _id_to_danger_zone.erase(id)


func _try_attack(id: int, pc: Sprite) -> void:
	var lose: bool = false
	var __

	if _ref_ObjectData.verify_state(pc, _new_ObjectStateTag.ACTIVE):
		return

	for i in _id_to_danger_zone[id]:
		_set_danger_zone(i[0], i[1], false)
		if _ref_DungeonBoard.has_sprite_with_sub_tag(
				_new_MainGroupTag.ACTOR, _new_SubGroupTag.PC, i[0], i[1]):
			lose = true
	_ref_SwitchSprite.switch_sprite(_self, _new_SpriteTypeTag.DEFAULT)
	__ = _id_to_danger_zone.erase(id)

	if lose:
		_ref_EndGame.player_lose()


func _reset_hit_point() -> void:
	var hp: int = _ref_RandomNumber.get_int(
			_new_FrogData.MIN_WAIT, _new_FrogData.MAX_WAIT)
	_ref_ObjectData.set_hit_point(_self, hp)


func _can_grapple(pc: Sprite) -> bool:
	var self_x: int = _self_pos[0]
	var self_y: int = _self_pos[1]
	var pc_x: int = _pc_pos[0]
	var pc_y: int = _pc_pos[1]
	var middle_x: int = ((self_x + pc_x) / 2.0) as int
	var middle_y: int = ((self_y + pc_y) / 2.0) as int

	if _ref_ObjectData.verify_state(pc, _new_ObjectStateTag.PASSIVE):
		return false
	if _new_CoordCalculator.is_inside_range(self_x, self_y, pc_x, pc_y,
			_new_FrogData.ATTACK_RANGE):
		if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR,
				middle_x, middle_y):
			return false
		return true
	return false


func _grapple(id: int) -> void:
	var neighbor: Array = _new_CoordCalculator.get_neighbor(
			_self_pos[0], _self_pos[1], _new_FrogData.ATTACK_RANGE)
	var pc_move: Array = _new_CoordCalculator.get_neighbor(
			_pc_pos[0], _pc_pos[1], 1, true)

	_id_to_danger_zone[id] = []
	_new_ArrayHelper.filter_element(neighbor, self, "_filter_grapple",
			[pc_move])
	for i in neighbor:
		_id_to_danger_zone[id].push_back(i)
		_set_danger_zone(i[0], i[1], true)
	_ref_SwitchSprite.switch_sprite(_self, _new_SpriteTypeTag.ACTIVE)


func _random_walk() -> void:
	var x: int = _self_pos[0]
	var y: int = _self_pos[1]
	var max_distance: int = _new_CoordCalculator.get_range(
			x, y, _pc_pos[0], _pc_pos[1])
	var neighbor: Array = _new_CoordCalculator.get_neighbor(x, y, 1, false)

	_new_ArrayHelper.filter_element(neighbor, self, "_filter_rand_walk", [])
	_new_ArrayHelper.duplicate_element(neighbor, self, "_dup_rand_walk",
			[max_distance])
	if neighbor.size() < 1:
		return

	_new_ArrayHelper.random_picker(neighbor, 1, _ref_RandomNumber)
	x = neighbor[0][0]
	y = neighbor[0][1]
	_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR, _self_pos, [x, y])


func _set_danger_zone(x: int, y: int, danger: bool) -> void:
	var ground: Sprite = _ref_DungeonBoard.get_sprite(
			_new_MainGroupTag.GROUND, x, y)

	_ref_DangerZone.set_danger_zone(x, y, danger)
	if _ref_DangerZone.is_in_danger(x, y):
		_ref_SwitchSprite.switch_sprite(ground, _new_SpriteTypeTag.ACTIVE)
	else:
		_ref_SwitchSprite.switch_sprite(ground, _new_SpriteTypeTag.DEFAULT)


func _filter_grapple(source: Array, index: int, opt_arg: Array) -> bool:
	var pc_move: Array = opt_arg[0]
	return source[index] in pc_move


func _filter_rand_walk(source: Array, index: int, _opt_arg: Array) -> bool:
	if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR,
			source[index][0], source[index][1]):
		return false
	return true


func _dup_rand_walk(source: Array, index: int, opt_arg: Array) -> int:
	var repeat: int = 1
	var x: int = source[index][0]
	var y: int = source[index][1]
	var pc_x: int = _pc_pos[0]
	var pc_y: int = _pc_pos[1]
	var max_distance: int = opt_arg[0]

	if _new_CoordCalculator.is_inside_range(x, y, pc_x, pc_y, max_distance):
		repeat += 1
	if _ref_DungeonBoard.has_sprite_with_sub_tag(
			_new_MainGroupTag.GROUND, _new_SubGroupTag.SWAMP, x, y):
		repeat += 1
	return repeat
