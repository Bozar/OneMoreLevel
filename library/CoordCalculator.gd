class_name Game_CoordCalculator


func get_range(x_source: int, y_source: int, x_target: int, y_target: int) \
		-> int:
	var delta_x: int = abs(x_source - x_target) as int
	var delta_y: int = abs(y_source - y_target) as int

	return delta_x + delta_y


func is_inside_range(x_source: int, y_source: int, x_target: int, y_target: int,
		 max_range: int) -> bool:
	return get_range(x_source, y_source, x_target, y_target) <= max_range


func get_neighbor(x: int, y: int, max_range: int, has_center: bool = false) \
		-> Array:
	var neighbor: Array = []

	for i in range(x - max_range, x + max_range + 1):
		for j in range(y - max_range, y + max_range + 1):
			if (i == x) and (j == y):
				continue
			if is_inside_dungeon(i, j) \
					and is_inside_range(x, y, i, j, max_range):
				neighbor.push_back([i, j])

	if has_center:
		neighbor.push_back([x, y])

	return neighbor


func get_block(x_top_left: int, y_top_left: int, width: int, height: int) \
		-> Array:
	var coord: Array = []

	for i in range(x_top_left, x_top_left + width):
		for j in range(y_top_left, y_top_left + height):
			if is_inside_dungeon(i, j):
				coord.push_back([i, j])
	return coord


func get_mirror_image(source_x: int, source_y: int,
		center_x: int, center_y: int, force_output: bool = false) -> Array:
	var target_x: int = center_x * 2 - source_x
	var target_y: int = center_y * 2 - source_y

	if force_output or is_inside_dungeon(target_x, target_y):
		return [target_x, target_y]
	return []


func is_inside_dungeon(x: int, y: int) -> bool:
	return (x > -1) and (x < Game_DungeonSize.MAX_X) \
			and (y > -1) and (y < Game_DungeonSize.MAX_Y)
