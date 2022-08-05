class_name Game_CoordCalculator


const UP := 0
const DOWN := 1
const LEFT := 2
const RIGHT := 3

const DIRECTION_TO_SHIFT := {
	UP: [0, -1],
	DOWN: [0, 1],
	LEFT: [-1, 0],
	RIGHT: [1, 0],
}


static func get_range_xy(source_x: int, source_y: int,
		target_x: int, target_y: int) -> int:
	var delta_x: int = abs(source_x - target_x) as int
	var delta_y: int = abs(source_y - target_y) as int

	return delta_x + delta_y


static func get_range(source: Game_IntCoord, target: Game_IntCoord) -> int:
	return get_range_xy(source.x, source.y, target.x, target.y)


static func is_in_range_xy(source_x: int, source_y: int,
		target_x: int, target_y: int, max_range: int) -> bool:
	return get_range_xy(source_x, source_y, target_x, target_y) <= max_range


static func is_in_range(source: Game_IntCoord, target: Game_IntCoord,
		max_range: int) -> bool:
	return is_in_range_xy(source.x, source.y, target.x, target.y, max_range)


static func is_out_of_range_xy(source_x: int, source_y: int,
		target_x: int, target_y: int, max_range: int) -> bool:
	return not is_in_range_xy(source_x, source_y, target_x, target_y,
			max_range)


static func is_out_of_range(source: Game_IntCoord, target: Game_IntCoord,
		max_range: int) -> bool:
	return is_out_of_range_xy(source.x, source.y, target.x, target.y,
			max_range)


static func get_neighbor_xy(x: int, y: int, max_range: int,
		has_center := false) -> Array:
	var neighbor := []

	for i in range(x - max_range, x + max_range + 1):
		for j in range(y - max_range, y + max_range + 1):
			if (i == x) and (j == y):
				continue
			if is_inside_dungeon(i, j) \
					and is_in_range_xy(x, y, i, j, max_range):
				neighbor.push_back(Game_IntCoord.new(i, j))
	if has_center:
		neighbor.push_back(Game_IntCoord.new(x, y))
	return neighbor


static func get_neighbor(center: Game_IntCoord, max_range: int,
		has_center := false) -> Array:
	return get_neighbor_xy(center.x, center.y, max_range, has_center)


static func get_block(x_top_left: int, y_top_left: int, width: int,
		height: int) -> Array:
	var coord := []

	for i in range(x_top_left, x_top_left + width):
		for j in range(y_top_left, y_top_left + height):
			if is_inside_dungeon(i, j):
				coord.push_back(Game_IntCoord.new(i, j))
	return coord


static func get_mirror_image_xy(source_x: int, source_y: int,
		center_x: int, center_y: int) -> Game_IntCoord:
	var x: int = center_x * 2 - source_x
	var y: int = center_y * 2 - source_y

	return Game_IntCoord.new(x, y)


static func get_mirror_image(source: Game_IntCoord, center: Game_IntCoord) \
		-> Game_IntCoord:
	return get_mirror_image_xy(source.x, source.y, center.x, center.y)


static func is_inside_dungeon(x: int, y: int) -> bool:
	return (x >= 0) and (x < Game_DungeonSize.MAX_X) \
			and (y >= 0) and (y < Game_DungeonSize.MAX_Y)


# ray_direction: Game_CoordCalculator.[UP|DOWN|LEFT|RIGHT]
# is_obstacle_func(x: int, y: int, optional_arg: Array) -> bool
# Return an array of coordinates: [Game_IntCoord, ...].
static func get_ray_path(source_x: int, source_y: int, max_range: int,
		ray_direction: int, has_start_point: bool, has_end_point: bool,
		func_host: Object, is_obstacle_func: String, optional_arg := []) \
		-> Array:
	var x: int = source_x
	var y: int = source_y
	var is_obstacle := funcref(func_host, is_obstacle_func)
	var shift: Array = DIRECTION_TO_SHIFT[ray_direction]
	var ray_path := []

	if has_start_point:
		ray_path.push_back(Game_IntCoord.new(x, y))
	for _i in range(0, max_range):
		x += shift[0]
		y += shift[1]
		if not is_inside_dungeon(x, y):
			return ray_path
		if is_obstacle.call_func(x, y, optional_arg):
			if has_end_point:
				ray_path.push_back(Game_IntCoord.new(x, y))
			return ray_path
		ray_path.push_back(Game_IntCoord.new(x, y))
	return ray_path


static func is_in_square(coord: Game_IntCoord, center: Game_IntCoord,
		half_size: int) -> bool:
	for i in ["x", "y"]:
		if abs(coord[i] - center[i]) > half_size:
			return false
	return true
