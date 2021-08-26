class_name Game_ShadowCastFOV


# Recursive Shadow Casting Field of View
#
# http://www.roguebasin.com/index.php?title=FOV_using_recursive_shadowcasting
#
# How to use it?
#
# 1. Call set_field_of_view(). It requires a function reference to decide
# whether a grid is occupied. Refer to FuncRef in Godot manual.
# 2. Call is_in_sight() to check if a grid is in sight.
#
# How does it work internally?
#
# 1. Divide the whole plane into eight parts.
# 2. Call _set_octant() to render octant 0. [*]
# 3. Call _convert_coord() to convert coordinates in another region to octant 0.
# Then use _set_octant() to render a new region.
#
# [*]
#
# 2.1 Beware that PC is in the center of eight octants. But the grid [0, 0]
# hangs on the top left corner of the screen.
# 2.2 In octant 0, the slope (delta_y / delta_x) ranges from 0 to 1. It does
# not grow to infinity. Besides, both coordinates are positive relative to PC's
# position.That's why we choose it as the first region.
#
#   \ 5 | 6 /
#    \  |  /
#   4 \ | / 7
# ------@------>
#   3 / | \ 0
#    /  |  \
#   / 2 | 1 \
#       |
#       v
#

const MIN_LEFT_SLOPE := 0.0
const MAX_RIGHT_SLOPE := 1.0
const MAX_OCTANT := 8

const _FOV_DATA := {
	"dungeon_width": 0,
	"dungeon_height": 0,
	"dungeon_board": {},
	"center_x": 0,
	"center_y": 0,
}


# block_ray_func(x: int, y: int, opt_arg: Array) -> bool
# Return true if a grid [x, y] is blocked.
static func set_field_of_view(dungeon_width: int, dungeon_height: int,
		x: int, y: int, max_range: int,
		func_host: Object, block_ray_func: String, opt_arg: Array) -> void:
	_FOV_DATA.dungeon_width = dungeon_width
	_FOV_DATA.dungeon_height = dungeon_height
	_reset_dungeon()

	_FOV_DATA.dungeon_board[x][y] = true
	_FOV_DATA.center_x = x
	_FOV_DATA.center_y = y

	for i in range(MAX_OCTANT):
		_set_octant(i, x, y, x + max_range, MIN_LEFT_SLOPE, MAX_RIGHT_SLOPE,
				func_host, block_ray_func, opt_arg)
	# _set_octant(3, x, y, x + max_range, MIN_LEFT_SLOPE, MAX_RIGHT_SLOPE,
	# 		func_host, block_ray_func, opt_arg)


static func is_in_sight(x: int, y: int) -> bool:
	return _FOV_DATA.dungeon_board[x][y]


static func _reset_dungeon() -> void:
	if _FOV_DATA.dungeon_board.size() == 0:
		for x in range(0, _FOV_DATA.dungeon_width):
			_FOV_DATA.dungeon_board[x] = []
			_FOV_DATA.dungeon_board[x].resize(_FOV_DATA.dungeon_height)
	for x in range(0, _FOV_DATA.dungeon_width):
		for y in range(0, _FOV_DATA.dungeon_height):
			_FOV_DATA.dungeon_board[x][y] = false


static func _set_octant(which_octant: int, source_x: int, source_y: int,
		max_x: int, left_slope: float, right_slope: float,
		func_host: Object, block_ray_func: String, opt_arg: Array) -> void:
	var max_y: int
	var min_y: int
	var block_ray := funcref(func_host, block_ray_func)
	var is_blocked: bool
	var end_loop: bool
	var convert_x: int
	var convert_y: int
	var sub_left_slope: float
	var sub_y: int

	for x in range(source_x + 1, max_x, 1):
		# If a ray passes through a grid, the grid is visible. Therefore in
		# octant 0, the right slope should be slightly lower to include the
		# maximum integer y, and the left slope should be slightly higher to
		# include the minimum integer y.
		max_y = ceil(right_slope * (x - source_x) + source_y) as int
		min_y = floor(left_slope * (x - source_x) + source_y) as int
		# Include half of an axis (x or y). Both axes are calculated twice.
		min_y -= 1
		is_blocked = false
		# Scan just one column by default.
		end_loop = true

		for y in range(max_y, min_y, -1):
			# _set_octant() is designed for octant 0 by default. Convert
			# coordinates so that we can use the same function for all octants.
			convert_x = _convert_coord(which_octant, x, y, true)
			convert_y = _convert_coord(which_octant, x, y, false)
			if not _is_inside_dungeon(convert_x, convert_y):
				continue
			_FOV_DATA.dungeon_board[convert_x][convert_y] = true

			if block_ray.call_func(convert_x, convert_y, opt_arg):
				# Call _set_octant() recursively only if this is the first block
				# in a continuous cloumn.
				if is_blocked:
					continue
				is_blocked = true
				# Step back 1 grid. Try to set a new start point and sub left
				# slope.
				sub_y = y + 1
				if sub_y > max_y:
					continue
				sub_left_slope = _get_slope(source_x, source_y, x, sub_y)
				# Start a recursive call.
				_set_octant(which_octant, x, sub_y, max_x,
						sub_left_slope, right_slope,
						func_host, block_ray_func, opt_arg)
			else:
				# Set a new right slope after leaving a continuous column of
				# blocks.
				if is_blocked:
					is_blocked = false
					right_slope = _get_slope(source_x, source_y, x, y)
				# Quote from RogueBasin: "Ok, once a scan has reached it's last
				# cell the scan is finished and a new scan is started one row
				# further away if, and only if, the last cell was a non-blocking
				# cell."
				if y == min_y + 1:
					end_loop = false
		if end_loop:
			break


static func _get_slope(source_x: int, source_y: int,
		target_x: int, target_y: int) -> float:
	return (target_y - source_y) / ((target_x - source_x) as float)


static func _convert_coord(octant: int, source_x: int, source_y: int,
		is_x_coord: bool) -> int:
	var x: int
	var y: int

	match octant:
		0:
			x = source_x
			y = source_y
		1:
			x = _FOV_DATA.center_x + (source_y - _FOV_DATA.center_y)
			y = _FOV_DATA.center_y + (source_x - _FOV_DATA.center_x)
		2:
			x = _FOV_DATA.center_x - (source_y - _FOV_DATA.center_y)
			y = _FOV_DATA.center_y + (source_x - _FOV_DATA.center_x)
		3:
			x = _FOV_DATA.center_x - (source_x - _FOV_DATA.center_x)
			y = source_y
		4:
			x = _FOV_DATA.center_x - (source_x - _FOV_DATA.center_x)
			y = _FOV_DATA.center_y - (source_y - _FOV_DATA.center_y)
		5:
			x = _FOV_DATA.center_x - (source_y - _FOV_DATA.center_y)
			y = _FOV_DATA.center_y - (source_x - _FOV_DATA.center_x)
		6:
			x = _FOV_DATA.center_x + (source_y - _FOV_DATA.center_y)
			y = _FOV_DATA.center_y - (source_x - _FOV_DATA.center_x)
		7:
			x = source_x
			y = _FOV_DATA.center_y - (source_y - _FOV_DATA.center_y)
		_:
			x = source_x
			y = source_y

	if is_x_coord:
		return x
	return y


static func _is_inside_dungeon(x: int, y: int) -> bool:
	return (x > -1) and (x < _FOV_DATA.dungeon_width) \
			and (y > -1) and (y < _FOV_DATA.dungeon_height)
