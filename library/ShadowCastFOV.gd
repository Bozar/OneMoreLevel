# http://www.roguebasin.com/index.php?title=FOV_using_recursive_shadowcasting

const MIN_LEFT_SLOPE: float = 0.0
const MAX_RIGHT_SLOPE: float = 1.0

var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()
var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()

var _dungeon: Dictionary


func set_field_of_view(x: int, y: int, max_range: int,
		func_host: Object, block_ray_func: String, opt_arg: Array) -> void:
	_reset_dungeon()

	_set_octant(x, y, x + max_range, MIN_LEFT_SLOPE, MAX_RIGHT_SLOPE,
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


func _set_octant(source_x: int, source_y: int, max_x: int,
		left_slope: float, right_slope: float,
		func_host: Object, block_ray_func: String, opt_arg: Array) -> void:
	var max_y: int
	var min_y: int
	var block_ray := funcref(func_host, block_ray_func)
	var is_blocked: bool
	var break_loop: bool
	var sub_left_slope: float
	var sub_y: int

	for x in range(source_x + 1, max_x, 1):
		max_y = floor(right_slope * (x - source_x) + source_y) as int
		min_y = floor(left_slope * (x - source_x) + source_y) as int
		is_blocked = false
		break_loop = true

		for y in range(max_y, min_y, -1):
			# TODO: Convert [x, y]
			if not _new_CoordCalculator.is_inside_dungeon(x, y):
				continue
			break_loop = false
			_dungeon[x][y] = true

			if block_ray.call_func(x, y, opt_arg):
				break_loop = true
				if is_blocked:
					continue
				is_blocked = true
				sub_y = y + 1
				if sub_y > max_y:
					continue
				sub_left_slope = _get_slope(source_x, source_y, x, sub_y)
				_set_octant(x, sub_y, max_x, sub_left_slope, right_slope,
						func_host, block_ray_func, opt_arg)
			else:
				if is_blocked:
					is_blocked = false
					break_loop = false
					right_slope = _get_slope(source_x, source_y, x, y)
		if break_loop:
			break


func _get_slope(source_x: int, source_y: int,
		target_x: int, target_y: int) -> float:
	return (target_y - source_y) / ((target_x - source_x) as float)
