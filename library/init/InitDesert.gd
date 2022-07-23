extends Game_WorldTemplate


var _spr_PCDesert := preload("res://sprite/PCDesert.tscn")
var _spr_Treasure := preload("res://sprite/Treasure.tscn")


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_init_floor()
	_init_wall()
	_init_pc(0, INVALID_COORD, INVALID_COORD, _spr_PCDesert)

	return _blueprint


func _init_wall(count: int = 0) -> void:
	var max_repeat: int = 20
	if count > max_repeat:
		return

	var min_length: int = 3
	var max_length: int = 6
	var wall_length: int = _ref_RandomNumber.get_int(min_length, max_length)
	var treasure: int = _ref_RandomNumber.get_int(0, wall_length)
	var x: int = _ref_RandomNumber.get_int(0, Game_DungeonSize.MAX_X)
	var y: int = _ref_RandomNumber.get_int(0, Game_DungeonSize.MAX_Y)
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
	if not Game_CoordCalculator.is_inside_dungeon(x, y):
		return
	if _is_occupied(x, y):
		return

	_occupy_position(x, y)
	if is_treasure:
		_add_trap_to_blueprint(_spr_Treasure, Game_SubTag.TREASURE, x, y)
	else:
		_add_building_to_blueprint(_spr_Wall, Game_SubTag.WALL, x, y)
