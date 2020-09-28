extends "res://library/game_progress/ProgressTemplate.gd"


var _spr_WormHead := preload("res://sprite/WormHead.tscn")

var _new_DesertData := preload("res://library/npc_data/DesertData.gd").new()

var _remove_sprite: Array
var _respawn_counter: Array = []


func _init(parent_node: Node2D).(parent_node) -> void:
	_remove_sprite = [
		_new_MainGroupTag.BUILDING, _new_MainGroupTag.TRAP
	]

	for _i in range(_new_DesertData.MAX_WORM):
		_respawn_counter.push_back(-1)


func renew_world(_pc_x: int, _pc_y: int) -> void:
	for i in range(_respawn_counter.size()):
		if _respawn_counter[i] == -1:
			continue

		if _respawn_counter[i] == 0:
			_create_worm_head()
		_respawn_counter[i] -= 1


func remove_actor(actor: Sprite, _x: int, _y: int) -> void:
	if not actor.is_in_group(_new_SubGroupTag.WORM_HEAD):
		return

	for i in range(_respawn_counter.size()):
		if _respawn_counter[i] == -1:
			_respawn_counter[i] = _ref_RandomNumber.get_int(
					0, _new_DesertData.MAX_COOLDOWN)
			break


func _create_worm_head(stop_loop: bool = false) -> void:
	if stop_loop:
		return

	var x: int
	var y: int
	var neighbor: Array

	x = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_X)
	y = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y)
	neighbor = _new_CoordCalculator.get_neighbor(x, y,
			_new_DesertData.WORM_DISTANCE, true)

	for i in neighbor:
		if _ref_DungeonBoard.has_sprite(
				_new_MainGroupTag.ACTOR, i[0], i[1]):
			_create_worm_head(false)
			return

	for j in _remove_sprite:
		if _ref_DungeonBoard.has_sprite(j, x, y):
			_ref_RemoveObject.remove(j, x, y)
	_ref_CreateObject.create(
			_spr_WormHead,
			_new_MainGroupTag.ACTOR, _new_SubGroupTag.WORM_HEAD,
			x, y)
	_create_worm_head(true)
