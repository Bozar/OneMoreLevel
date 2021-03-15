# http://www.roguebasin.com/index.php?title=FOV_using_recursive_shadowcasting

var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()
var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()

var _dungeon: Dictionary


func set_field_of_view(x: int, y: int, max_range: int,
		func_host: Object, block_ray_func: String, opt_arg: Array) -> void:
	_reset_dungeon()

	_set_octant(x, y, max_range,
			_get_slope(x, y, x + max_range, x + max_range),
			_get_slope(x, y, x + max_range, y),
			func_host, block_ray_func, opt_arg)


func is_in_sight(x: int, y: int) -> bool:
	return _dungeon[x][y]


func _reset_dungeon() -> void:
	if _dungeon.size() == 0:
		for x in range(_new_DungeonSize.MAX_X):
			_dungeon[x] = []
			_dungeon[x].resize(_new_DungeonSize.MAX_Y)
	for x in range(_new_DungeonSize.MAX_X):
		for y in range(_new_DungeonSize.MAX_Y):
			_dungeon[x][y] = false


func _set_octant(_source_x: int, _source_y: int, _max_x: int,
		_left_slope: float, _right_slope: float,
		_func_host: Object, _block_ray_func: String, _opt_arg: Array) -> void:
	# var block_ray := funcref(func_host, block_ray_func)

	# block_ray.call_func(source_x, source_y, opt_arg)
	pass


func _get_slope(source_x: int, source_y: int,
		target_x: int, target_y: int) -> float:
	return (target_y - source_y) / ((target_x - source_x) as float)
