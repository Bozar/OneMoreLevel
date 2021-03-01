# PC's field of view is consisted of three rays.
# The width of each ray is: 1 + half_width * 2.
#
#  $
#  | side range
#  |
#  @ - front range ->
#  |
#  | side range
#  $
#
# Call set_rectangular_sight() to set local data.
# Then call is_in_sight() to check whether a given position is in sight.
# Make sure that nothing changes between these two calls.


var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()

var _max_x: int
var _max_y: int
var _min_x: int
var _min_y: int
var _center_x: int
var _center_y: int
var _half_width: int


# is_obstacle_func(x: int, y: int, optional_arg: Array) -> bool
func set_rectangular_sight(center_x: int, center_y: int,
		face_x: int, face_y: int,
		front_range: int, side_range: int, half_width: int,
		func_host: Object, is_obstacle_func: String,
		optional_arg: Array) -> void:
	var is_obstacle := funcref(func_host, is_obstacle_func)
	var end_point: Array
	var side_view: Array

	# Set initial data.
	_center_x = center_x
	_max_x = center_x
	_min_x = center_x

	_center_y = center_y
	_max_y = center_y
	_min_y = center_y

	_half_width = half_width

	# Cast a ray to the front.
	end_point = _cast_ray(center_x, center_y, face_x, face_y, front_range,
			is_obstacle, optional_arg)
	_update_min_max(end_point[0], end_point[1])

	# Cast rays to both sides.
	if face_x == 0:
		side_view = [[1, 0], [-1, 0]]
	else:
		side_view = [[0, 1], [0, -1]]
	for i in side_view:
		end_point = _cast_ray(center_x, center_y, i[0], i[1], side_range,
				is_obstacle, optional_arg)
		_update_min_max(end_point[0], end_point[1])

	# Expand the rectangular a little bit as a ray has a width.
	_update_min_max(
		center_x - face_x * half_width,
		center_y - face_y * half_width
	)


func is_in_sight(x: int, y: int) -> bool:
	if (x < _min_x) or (x > _max_x) or (y < _min_y) or (y > _max_y):
		return false
	elif (abs(x - _center_x) > _half_width) \
			and (abs(y - _center_y) > _half_width):
		return false
	return true


func _cast_ray(start_x: int, start_y: int, shift_x: int, shift_y: int,
		max_range: int, is_obstacle: FuncRef, optional_arg: Array) -> Array:
	var x: int = start_x
	var y: int = start_y

	for _i in range(max_range):
		x += shift_x
		y += shift_y
		if not _new_CoordCalculator.is_inside_dungeon(x, y):
			x -= shift_x
			y -= shift_y
			break
		elif is_obstacle.call_func(x, y, optional_arg):
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
