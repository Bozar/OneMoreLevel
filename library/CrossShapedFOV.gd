class_name Game_CrossShapedFOV


# How to use it?
#
# 1: Call set_rectangular_sight() to set local data. [*]
# 2: Call is_in_sight() to check whether a given position is in sight.
#
# [*]
#
# 1.1 Beware that [face_x, face_y] could only be [x, 0] or [0, y]. The coord
# points to a cardinal direction relative to [center_x, center_y].
# 1.2 The function requires four ranges in clock wise direction, starting from
# front_range.
# 1.3 It also requires a function reference to decide whether a grid is
# occupied. Refer to FuncRef in Godot manual.
# 1.4 Optionally, call set_t_shaped_sight() or set_symmetric_sight(). They wrap
# around set_rectangular_sight() and accept fewer arguments to create a more
# symmetric field of view.
#
# How does it work internally?
#
# PC's field of view is consisted of four rays. The width of each ray is:
# 1 + half_width * 2.
#
#          	^
#          	| left
#          	|
# <- back - @ - front ->
#          	|
#          	| right
#          	v
#
# In set_rectangular_sight(), cast four rays from PC's position until they hit
# obstacles. Record the farthest position a ray can reach. Four rays result in
# four positions. We can draw a rectangle based on them which limits PC's
# field of view.
#
# In is_in_sight(), first we check whether a given grid [x, y] is inside the
# rectangle. Then we verify if it is close enough to an axis.
#

const COORD_WARNING := "Neither face_x nor face_y is zero."
const T_SHAPED_BACK := 1
const SYMMETRIC_X := 0
const SYMMETRIC_Y := 1

const _FOV_DATA := {
	"dungeon_width": 0,
	"dungeon_height": 0,
	"max_x": 0,
	"max_y": 0,
	"min_x": 0,
	"min_y": 0,
	"center_x": 0,
	"center_y": 0,
	"half_width": 0,
}


# is_obstacle_func(x: int, y: int, opt_arg: Array) -> bool
# Return true if a grid [x, y] is blocked.
static func set_rectangular_sight(dungeon_width: int, dungeon_height: int,
		center_x: int, center_y: int,
		face_x: int, face_y: int, half_width: int,
		front_range: int, right_range: int, back_range: int, left_range: int,
		func_host: Object, is_obstacle_func: String, opt_arg: Array) -> void:
	var is_obstacle := funcref(func_host, is_obstacle_func)
	var end_point: Array
	var cast_ray_arg: Array

	# Set initial data.
	_FOV_DATA.dungeon_width = dungeon_width
	_FOV_DATA.dungeon_height = dungeon_height

	_FOV_DATA.center_x = center_x
	_FOV_DATA.center_y = center_y

	_FOV_DATA.max_x = center_x
	_FOV_DATA.max_y = center_y

	_FOV_DATA.min_x = center_x
	_FOV_DATA.min_y = center_y

	_FOV_DATA.half_width = half_width

	face_x = _normalize_coord(face_x)
	face_y = _normalize_coord(face_y)
	if (face_x != 0) and (face_y != 0):
		push_warning(COORD_WARNING)

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
			[-face_x, face_y, back_range],
			[face_y, -face_x, right_range],
			[face_y, face_x, left_range],
		]

	# Update four end points.
	for i in cast_ray_arg:
		end_point = _cast_ray(center_x, center_y, i[0], i[1], i[2],
				is_obstacle, opt_arg)
		_update_min_max(end_point[0], end_point[1])


static func set_t_shaped_sight(dungeon_width: int, dungeon_height: int,
		center_x: int, center_y: int,
		face_x: int, face_y: int, half_width: int,
		front_range: int, side_range: int,
		func_host: Object, is_obstacle_func: String, opt_arg: Array) -> void:
	set_rectangular_sight(dungeon_width, dungeon_height,
			center_x, center_y, face_x, face_y,
			half_width, front_range, side_range, T_SHAPED_BACK, side_range,
			func_host, is_obstacle_func, opt_arg)


static func set_symmetric_sight(dungeon_width: int, dungeon_height: int,
		center_x: int, center_y: int,
		half_width: int, max_range: int,
		func_host: Object, is_obstacle_func: String, opt_arg: Array) -> void:
	set_rectangular_sight(dungeon_width, dungeon_height,
			center_x, center_y, SYMMETRIC_X, SYMMETRIC_Y,
			half_width, max_range, max_range, max_range, max_range,
			func_host, is_obstacle_func, opt_arg)


static func is_in_sight(x: int, y: int) -> bool:
	if _is_outside_range(x, _FOV_DATA.min_x, _FOV_DATA.max_x) \
			or _is_outside_range(y, _FOV_DATA.min_y, _FOV_DATA.max_y):
		return false
	elif _is_outside_half_width(x, _FOV_DATA.center_x) \
			and _is_outside_half_width(y, _FOV_DATA.center_y):
		return false
	return true


static func _cast_ray(start_x: int, start_y: int, shift_x: int, shift_y: int,
		max_range: int, is_obstacle: FuncRef, opt_arg: Array) -> Array:
	var x: int = start_x
	var y: int = start_y

	for _i in range(max_range):
		x += shift_x
		y += shift_y
		if not _is_inside_dungeon(x, y):
			x -= shift_x
			y -= shift_y
			break
		elif is_obstacle.call_func(x, y, opt_arg):
			break
	return [x, y]


static func _update_min_max(x: int, y: int) -> void:
	if x > _FOV_DATA.max_x:
		_FOV_DATA.max_x = x
	elif x < _FOV_DATA.min_x:
		_FOV_DATA.min_x = x

	if y > _FOV_DATA.max_y:
		_FOV_DATA.max_y = y
	elif y < _FOV_DATA.min_y:
		_FOV_DATA.min_y = y


static func _normalize_coord(coord: int) -> int:
	if (coord > 1) or (coord < -1):
		coord = floor(coord / abs(coord)) as int
	return coord


static func _is_inside_dungeon(x: int, y: int) -> bool:
	return (x > -1) and (x < _FOV_DATA.dungeon_width) \
			and (y > -1) and (y < _FOV_DATA.dungeon_height)


static func _is_outside_range(x: int, min_x: int, max_x: int) -> bool:
	return (x < min_x) or (x > max_x)


static func _is_outside_half_width(x: int, center_x: int) -> bool:
	return abs(x - center_x) > _FOV_DATA.half_width
