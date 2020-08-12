extends "res://library/npc_ai/AITemplate.gd"


var _spr_WormBody := preload("res://sprite/WormBody.tscn")
var _spr_WormSpice := preload("res://sprite/WormSpice.tscn")
var _spr_WormTail := preload("res://sprite/WormTail.tscn")
var _spr_Treasure := preload("res://sprite/Treasure.tscn")
var _spr_Wall := preload("res://sprite/Wall.tscn")

var _new_DesertData := preload("res://library/npc_data/DesertData.gd")

# int: Array[Sprite]
var _id_to_worm: Dictionary = {}


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action(actor) -> void:
	if not actor.is_in_group(_new_SubGroupTag.WORM_HEAD):
		return

	var id: int = actor.get_instance_id()

	_set_local_var(actor)
	if not _id_to_worm.has(id):
		_init_worm(actor)

	if _can_bury_worm(id):
		_bury_worm(id)
		return

	# Try to move head.
	if _try_random_walk():
		# Move body.
		_move_body(id)
	else:
		_ref_ObjectData.add_hit_point(actor, _new_DesertData.HP_WAIT)
	_ref_ObjectData.add_hit_point(actor, _new_DesertData.HP_TURN)


func _init_worm(head: Sprite) -> void:
	var id: int = head.get_instance_id()
	var worm_length: int = _ref_RandomNumber.get_int(
			_new_DesertData.MIN_LENGTH, _new_DesertData.MAX_LENGTH)

	_id_to_worm[id] = []
	_id_to_worm[id].resize(worm_length)
	_id_to_worm[id][0] = head


func _create_body(id: int, index: int, x: int, y: int) -> void:
	var worm_length: int = _id_to_worm[id].size()
	var spice_end: int = min(
		_new_DesertData.SPICE_LEFT_END,
		worm_length - _new_DesertData.SPICE_RIGHT_END
	) as int

	# Create tail.
	if index == worm_length - 1:
		_ref_CreateObject.create(
				_spr_WormTail,
				_new_MainGroupTag.ACTOR, _new_SubGroupTag.WORM_BODY,
				x, y)
	# Create spice.
	elif (index > _new_DesertData.SPICE_START) and (index < spice_end):
		_ref_CreateObject.create(
				_spr_WormSpice,
				_new_MainGroupTag.ACTOR, _new_SubGroupTag.WORM_SPICE,
				x, y)
	# Create body.
	else:
		_ref_CreateObject.create(
				_spr_WormBody,
				_new_MainGroupTag.ACTOR, _new_SubGroupTag.WORM_BODY,
				x, y)

	_id_to_worm[id][index] = _ref_DungeonBoard.get_sprite(
			_new_MainGroupTag.ACTOR, x, y)


func _try_random_walk() -> bool:
	var x: int = _self_pos[0]
	var y: int = _self_pos[1]
	var neighbor: Array = _new_CoordCalculator.get_neighbor(x, y, 1)
	var candidate: Array = []
	var move_to: Array
	var remove_sprite: Array = [
		_new_MainGroupTag.BUILDING, _new_MainGroupTag.TRAP
	]

	for i in neighbor:
		if _is_pc_pos(i[0], i[1]):
			candidate.push_back(i)
		elif _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR, i[0], i[1]):
			continue
		candidate.push_back(i)

	if candidate.size() < 1:
		return false
	move_to = candidate[_ref_RandomNumber.get_int(0, candidate.size())]

	if _is_pc_pos(move_to[0], move_to[1]):
		_ref_SwitchSprite.switch_sprite(_pc, _new_SpriteTypeTag.ACTIVE)
		_ref_SwitchSprite.switch_sprite(_self, _new_SpriteTypeTag.ACTIVE)
		_ref_EndGame.player_lose()
		return false

	for i in remove_sprite:
		if _ref_DungeonBoard.has_sprite(i, move_to[0], move_to[1]):
			_ref_RemoveObject.remove(i, move_to[0], move_to[1])
	_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR, _self_pos, move_to)
	return true


func _is_pc_pos(x: int, y: int) -> bool:
	return (x == _pc_pos[0]) and (y == _pc_pos[1])


func _move_body(id: int) -> void:
	var worm: Array = _id_to_worm[id]
	var current_position: Array = _self_pos
	var save_position: Array

	for i in range(1, worm.size()):
		if worm[i] == null:
			_create_body(id, i, current_position[0], current_position[1])
			return

		save_position = _new_ConvertCoord.vector_to_array(worm[i].position)
		_ref_DungeonBoard.move_sprite(
				_new_MainGroupTag.ACTOR, save_position, current_position)
		current_position = save_position


func _bury_worm(id: int) -> void:
	var whole_worm: Array = _id_to_worm[id]
	var worm_position: Array
	var __

	for i in whole_worm:
		if i == null:
			return

		worm_position = _new_ConvertCoord.vector_to_array(i.position)
		_ref_RemoveObject.remove(
				_new_MainGroupTag.ACTOR, worm_position[0], worm_position[1])

		if _ref_RandomNumber.get_percent_chance(_new_DesertData.CREATE_SPICE):
			_ref_CreateObject.create(
					_spr_Treasure,
					_new_MainGroupTag.TRAP, _new_SubGroupTag.TREASURE,
					worm_position[0], worm_position[1])
		else:
			_ref_CreateObject.create(
					_spr_Wall,
					_new_MainGroupTag.BUILDING, _new_SubGroupTag.WALL,
					worm_position[0], worm_position[1])

	__ = _id_to_worm.erase(id)


func _can_bury_worm(id: int) -> bool:
	var worm: Array = _id_to_worm[id]
	var hit_point: int = _ref_ObjectData.get_hit_point(worm[0])

	for i in worm:
		if i == null:
			break
		if i.is_in_group(_new_SubGroupTag.WORM_SPICE) \
				and _ref_ObjectData.verify_state(
						i, _new_ObjectStateTag.PASSIVE):
			hit_point += _new_DesertData.HP_SPICE
	return hit_point > _new_DesertData.HP_BURY
