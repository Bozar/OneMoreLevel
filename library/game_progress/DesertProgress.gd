extends "res://library/game_progress/ProgressTemplate.gd"


var _spr_WormHead := preload("res://sprite/WormHead.tscn")

var _remove_sprite: Array


func _init(parent_node: Node2D).(parent_node) -> void:
	_remove_sprite = [
		_new_MainGroupTag.BUILDING, _new_MainGroupTag.TRAP
	]


func remove_npc(npc: Sprite, _x: int, _y: int) -> void:
	if not npc.is_in_group(_new_SubGroupTag.WORM_HEAD):
		return
	_create_worm_head()


func _create_worm_head(stop_loop: bool = false) -> void:
	if stop_loop:
		return

	var x: int
	var y: int
	var neighbor: Array

	x = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_X)
	y = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y)
	neighbor = _new_CoordCalculator.get_neighbor(x, y, 2, true)

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
