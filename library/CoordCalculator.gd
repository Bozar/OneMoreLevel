var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()


func get_range(source: Array, target: Array) -> int:
	var delta_x: int = abs(source[0] - target[0]) as int
	var delta_y: int = abs(source[1] - target[1]) as int

	return delta_x + delta_y


func is_inside_range(source: Array, target: Array, max_range: int) -> bool:
	return get_range(source, target) <= max_range


func get_neighbor(center: Array, max_range: int, has_center: bool = false) \
		-> Array:
	var x: int = center[0]
	var y: int = center[1]
	var neighbor: Array = []

	for i in range(x - max_range, x + max_range + 1):
		for j in range(y - max_range, y + max_range + 1):
			if (i == x) and (j == y):
				continue
			if is_inside_dungeon(i, j) \
					and is_inside_range([x, y], [i, j], max_range):
				neighbor.push_back([i, j])

	if has_center:
		neighbor.push_back([x, y])

	return neighbor


func get_block(top_left: Array, width: int, height: int) -> Array:
	var x: int = top_left[0]
	var y: int = top_left[1]
	var coord: Array = []

	for i in range(x, x + width):
		for j in range(y, y + height):
			if is_inside_dungeon(i, j):
				coord.push_back([i, j])

	return coord


func is_inside_dungeon(x: int, y: int) -> bool:
	return (x > -1) and (x < _new_DungeonSize.MAX_X) \
			and (y > -1) and (y < _new_DungeonSize.MAX_Y)
