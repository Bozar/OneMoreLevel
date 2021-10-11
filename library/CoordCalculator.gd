class_name Game_CoordCalculator


class CoordPair:
	var is_in_dungeon: bool setget set_is_in_dungeon, \
			get_is_in_dungeon
	var x: int setget set_x, get_x
	var y: int setget set_y, get_y


	func _init(new_x: int = -1, new_y: int = -1) -> void:
		x = new_x
		y = new_y


	func get_is_in_dungeon() -> bool:
		return (x >= 0) and (x < Game_DungeonSize.MAX_X) \
				and (y >= 0) and (y < Game_DungeonSize.MAX_Y)


	func set_is_in_dungeon(__) -> void:
		pass


	func get_x() -> int:
		return x


	func set_x(new_x) -> void:
		x = new_x


	func get_y() -> int:
		return y


	func set_y(new_y) -> void:
		y = new_y


static func get_range(x_source: int, y_source: int,
		x_target: int, y_target: int) -> int:
	var delta_x: int = abs(x_source - x_target) as int
	var delta_y: int = abs(y_source - y_target) as int

	return delta_x + delta_y


static func is_inside_range(x_source: int, y_source: int,
		x_target: int, y_target: int, max_range: int) -> bool:
	return get_range(x_source, y_source, x_target, y_target) <= max_range


static func get_neighbor(x: int, y: int, max_range: int,
		has_center: bool = false) -> Array:
	var neighbor := []

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


static func get_block(x_top_left: int, y_top_left: int, width: int,
		height: int) -> Array:
	var coord := []

	for i in range(x_top_left, x_top_left + width):
		for j in range(y_top_left, y_top_left + height):
			if is_inside_dungeon(i, j):
				coord.push_back([i, j])
	return coord


static func get_mirror_image(source_x: int, source_y: int,
		center_x: int, center_y: int) -> CoordPair:
	var x: int = center_x * 2 - source_x
	var y: int = center_y * 2 - source_y

	return CoordPair.new(x, y)


static func is_inside_dungeon(x: int, y: int) -> bool:
	return (x >= 0) and (x < Game_DungeonSize.MAX_X) \
			and (y >= 0) and (y < Game_DungeonSize.MAX_Y)
