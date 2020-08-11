extends "res://library/npc_ai/AITemplate.gd"


var _spr_WormBody := preload("res://sprite/WormBody.tscn")
var _spr_WormSpice := preload("res://sprite/WormSpice.tscn")
var _spr_WormTail := preload("res://sprite/WormTail.tscn")

var _new_DesertData := preload("res://library/npc_data/DesertData.gd")

var _current_position: Array
var _wait_one_turn: bool = false
# int: Array[Sprite]
var _id_to_worm: Dictionary = {}


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action(actor) -> void:
	var id: int = actor.get_instance_id()
	var save_position: Array

	if not actor.is_in_group(_new_SubGroupTag.WORM_HEAD):
		return

	_set_local_var(actor)
	_current_position = _self_pos
	_random_walk()

	if not _id_to_worm.has(id):
		_init_worm(actor)
	if _wait_one_turn:
		return

	for i in range(1, _id_to_worm[id].size()):
		if not _id_to_worm[id][i]:
			_create_body(id, i)
			return
		save_position = _new_ConvertCoord.vector_to_array(
				_id_to_worm[id][i].position)
		_ref_DungeonBoard.move_sprite(
				_new_MainGroupTag.ACTOR, save_position, _current_position)
		_current_position = save_position


func _init_worm(head: Sprite) -> void:
	var id: int = head.get_instance_id()
	var worm_length: int = _ref_RandomNumber.get_int(
			_new_DesertData.MIN_LENGTH, _new_DesertData.MAX_LENGTH)

	_id_to_worm[id] = []
	_id_to_worm[id].resize(worm_length)
	_id_to_worm[id][0] = head


func _create_body(id: int, index: int) -> void:
	var worm_length: int = _id_to_worm[id].size()
	var spice_end: int = min(
		_new_DesertData.SPICE_LEFT_END,
		worm_length - _new_DesertData.SPICE_RIGHT_END
	) as int

	if index == worm_length - 1:
		_ref_CreateObject.create(
				_spr_WormTail,
				_new_MainGroupTag.ACTOR, _new_SubGroupTag.WORM_BODY,
				_current_position[0], _current_position[1])
	elif (index > _new_DesertData.SPICE_START) and (index < spice_end):
		_ref_CreateObject.create(
				_spr_WormSpice,
				_new_MainGroupTag.ACTOR, _new_SubGroupTag.WORM_SPICE,
				_current_position[0], _current_position[1])
	else:
		_ref_CreateObject.create(
				_spr_WormBody,
				_new_MainGroupTag.ACTOR, _new_SubGroupTag.WORM_BODY,
				_current_position[0], _current_position[1])

	_id_to_worm[id][index] = _ref_DungeonBoard.get_sprite(
			_new_MainGroupTag.ACTOR, _current_position[0], _current_position[1])


func _random_walk() -> void:
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
		_wait_one_turn = true
		return
	move_to = candidate[_ref_RandomNumber.get_int(0, candidate.size())]

	if _is_pc_pos(move_to[0], move_to[1]):
		_ref_SwitchSprite.switch_sprite(_pc, _new_SpriteTypeTag.ACTIVE)
		_ref_SwitchSprite.switch_sprite(_self, _new_SpriteTypeTag.ACTIVE)
		_ref_EndGame.player_lose()
		_wait_one_turn = true
		return

	for i in remove_sprite:
		if _ref_DungeonBoard.has_sprite(i, move_to[0], move_to[1]):
			_ref_RemoveObject.remove(i, move_to[0], move_to[1])
	_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR, _self_pos, move_to)


func _is_pc_pos(x: int, y: int) -> bool:
	return (x == _pc_pos[0]) and (y == _pc_pos[1])
