extends "res://library/npc_ai/AITemplate.gd"


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action(actor) -> void:
	_set_local_var(actor)

	if not actor.is_in_group(_new_SubGroupTag.WORM_HEAD):
		return
	_random_walk()


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
		return
	move_to = candidate[_ref_RandomNumber.get_int(0, candidate.size())]

	if _is_pc_pos(move_to[0], move_to[1]):
		_ref_SwitchSprite.switch_sprite(_pc, _new_SpriteTypeTag.ACTIVE)
		_ref_SwitchSprite.switch_sprite(_self, _new_SpriteTypeTag.ACTIVE)
		_ref_EndGame.player_lose()
		return

	for i in remove_sprite:
		if _ref_DungeonBoard.has_sprite(i, move_to[0], move_to[1]):
			_ref_RemoveObject.remove(i, move_to[0], move_to[1])
	_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR, _self_pos, move_to)


func _is_pc_pos(x: int, y: int) -> bool:
	return (x == _pc_pos[0]) and (y == _pc_pos[1])
