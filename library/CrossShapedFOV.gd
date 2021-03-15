# PC's field of view is consisted of four rays. The width of each ray is:
# 1 + half_width * 2.
#
#          	$
#          	| left
#          	|
# <- back - @ - front ->
#          	|
#          	| right
#          	$
#
# Call two functions in the given order. Make sure that PC does not move between
# these two calls.
#
# Step 1: Call set_rectangular_sight() to set local data.
#
# Beware that [center_x, center_y] and [face_x, face_y] should be on a straight
# line. The function requires four ranges in clock wise direction, starting from
# front_range.
#
# Optionally, call set_t_shaped_sight() or set_symmetric_sight(). They wrap
# around set_rectangular_sight() and accept fewer arguments to create a more
# symmetric field of view.
#
# Step 2: Call is_in_sight() to check whether a given position is in sight.
#


var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()

var _max_x: int
var _max_y: int
var _min_x: int
var _min_y: int
var _center_x: int
var _center_y: int
var _half_width: int


# is_obstacle_func(x: int, y: int, opt_arg: Array) -> bool
func set_rectangular_sight(center_x: int, center_y: int,
		face_x: int, face_y: int, half_width: int,
		front_range: int, right_range: int, back_range: int, left_range: int,
		func_host: Object, is_obstacle_func: String, opt_arg: Array) -> void:
	var is_obstacle := funcref(func_host, is_obstacle_func)
	var end_point: Array
	var cast_ray_arg: Array

	# Set initial data.
	_center_x = center_x
	_max_x = center_x
	_min_x = center_x

	_center_y = center_y
	_max_y = center_y
	_min_y = center_y

	_half_width = half_width

	face_x = _normalize_coord(face_x)
	face_y = _normalize_coord(face_y)

	if face_x == 0:
		cast_ray_arg = [
			[face_x, face_y, front_range],
			[face_x, -face_y, back_range],
			[face_y, face_x, right_range],
			[-face_y, face_x, left_range],
		]
	else:
		cast_ray_arg = [
			[face_x, face_y, front_range],
			[face_x, -face_y, back_range],
			[face_y, -face_x, right_range],
			[face_y, face_x, left_range],
		]

	# Update four rectangular end points.
	for i in cast_ray_arg:
		end_point = _cast_ray(center_x, center_y, i[0], i[1], i[2],
				is_obstacle, opt_arg)
		_update_min_max(end_point[0], end_point[1])


func set_t_shaped_sight(center_x: int, center_y: int,
		face_x: int, face_y: int, half_width: int,
		front_range: int, side_range: int,
		func_host: Object, is_obstacle_func: String, opt_arg: Array) -> void:
	set_rectangular_sight(center_x, center_y, face_x, face_y, half_width,
			front_range, side_range, 1, side_range,
			func_host, is_obstacle_func, opt_arg)


func set_symmetric_sight(center_x: int, center_y: int,
		face_x: int, face_y: int, half_width: int, max_range: int,
		func_host: Object, is_obstacle_func: String, opt_arg: Array) -> void:
	set_rectangular_sight(center_x, center_y, face_x, face_y, half_width,
			max_range, max_range, max_range, max_range,
			func_host, is_obstacle_func, opt_arg)


func is_in_sight(x: int, y: int) -> bool:
	if (x < _min_x) or (x > _max_x) or (y < _min_y) or (y > _max_y):
		return false
	elif (abs(x - _center_x) > _half_width) \
			and (abs(y - _center_y) > _half_width):
		return false
	return true


func _cast_ray(start_x: int, start_y: int, shift_x: int, shift_y: int,
		max_range: int, is_obstacle: FuncRef, opt_arg: Array) -> Array:
	var x: int = start_x
	var y: int = start_y

	for _i in range(max_range):
		x += shift_x
		y += shift_y
		if not _new_CoordCalculator.is_inside_dungeon(x, y):
			x -= shift_x
			y -= shift_y
			break
		elif is_obstacle.call_func(x, y, opt_arg):
			break
	return [x, y]


func _update_min_max(x: int, y: int) -> void:
	if x > _max_x:
		_max_x = x
	elif x < _min_x:
		_min_x = x

	if y > _max_y:
		_max_y = y
	elif y < _min_y:
		_min_y = y


func _normalize_coord(coord: int) -> int:
	if (coord > 1) or (coord < -1):
		coord = floor(coord / abs(coord)) as int
	return coord
