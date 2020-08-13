extends "res://library/init/WorldTemplate.gd"


var _spr_Treasure := preload("res://sprite/Treasure.tscn")
var _spr_WormHead := preload("res://sprite/WormHead.tscn")
var _spr_WormBody := preload("res://sprite/WormBody.tscn")
var _spr_WormSpice := preload("res://sprite/WormSpice.tscn")
var _spr_WormTail := preload("res://sprite/WormTail.tscn")

var _new_DesertData := preload("res://library/npc_data/DesertData.gd").new()


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_init_wall()
	_init_worm()
	_init_pc()

	return _blueprint


func _init_worm(count: int = 0) -> void:
	if count >= _new_DesertData.MAX_WORM:
		return

	var x: int
	var y: int
	var neighbor: Array

	while true:
		x = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_X)
		y = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y)
		if _is_occupied(x, y):
			continue

		_add_to_blueprint(_spr_WormHead,
				_new_MainGroupTag.ACTOR, _new_SubGroupTag.WORM_HEAD,
				x, y)

		neighbor = _new_CoordCalculator.get_neighbor(x, y, 2, true)
		for j in neighbor:
			_occupy_position(j[0], j[1])
		break

	count += 1
	_init_worm(count)


func _init_wall(count: int = 0) -> void:
	var max_repeat: int = 20
	if count > max_repeat:
		return

	var min_length: int = 3
	var max_length: int = 6
	var wall_length: int = _ref_RandomNumber.get_int(min_length, max_length)
	var treasure: int = _ref_RandomNumber.get_int(0, wall_length)
	var x: int = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_X)
	var y: int = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y)
	var direction: int = _ref_RandomNumber.get_int(0, 2)

	if direction == 0:
		for i in range(x, x + wall_length):
			_try_build_wall(i, y, i == x + treasure)
	elif direction == 1:
		for j in range(y, y + wall_length):
			_try_build_wall(x, j, j == y + treasure)

	count += 1
	_init_wall(count)


func _try_build_wall(x: int, y: int, is_treasure: bool) -> void:
	if not _new_CoordCalculator.is_inside_dungeon(x, y):
		return
	if _is_occupied(x, y):
		return

	_occupy_position(x, y)
	if is_treasure:
		_add_to_blueprint(_spr_Treasure,
				_new_MainGroupTag.TRAP, _new_SubGroupTag.TREASURE,
				x, y)
	else:
		_add_to_blueprint(_spr_Wall,
				_new_MainGroupTag.BUILDING, _new_SubGroupTag.WALL,
				x, y)
