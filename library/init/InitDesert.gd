extends "res://library/init/WorldTemplate.gd"


var _spr_PC := preload("res://sprite/PC.tscn")
var _spr_Wall := preload("res://sprite/Wall.tscn")


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_init_wall()
	_init_pc()

	return _blueprint


func _init_wall(count: int = 0) -> void:
	var max_repeat: int = 20
	if count > max_repeat:
		return

	var min_length: int = 3
	var max_length: int = 6
	var wall_length: int = _ref_RandomNumber.get_int(min_length, max_length)
	var x: int = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_X)
	var y: int = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y)
	var direction: int = _ref_RandomNumber.get_int(0, 2)

	if direction == 0:
		for i in range(x, x + wall_length):
			_try_build_wall(i, y)
	elif direction == 1:
		for j in range(y, y + wall_length):
			_try_build_wall(x, j)

	count += 1
	_init_wall(count)


func _try_build_wall(x: int, y: int) -> void:
	if not _new_CoordCalculator.is_inside_dungeon(x, y):
		return

	_occupy_position(x, y)
	_add_to_blueprint(_spr_Wall,
			_new_MainGroupTag.BUILDING, _new_SubGroupTag.WALL,
			x, y)


func _init_pc() -> void:
	var x: int
	var y: int

	while true:
		x = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_X)
		y = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y)

		if _is_occupied(x, y):
			continue
		break

	_occupy_position(x, y)
	_add_to_blueprint(_spr_PC,
			_new_MainGroupTag.ACTOR, _new_SubGroupTag.PC,
			x, y)
