class_name Game_DijkstraPathFinding


var _new_CoordCalculator := Game_CoordCalculator.new()
var _new_ArrayHelper := Game_ArrayHelper.new()


# Find the next step.
# Call func_host.is_passable_func() to verify if a grid can be entered.
# is_passable_func(source_array: Array, current_index: int,
#> opt_arg: Array) -> bool
func get_path(dungeon: Dictionary, start_x: int, start_y: int, one_step: int,
		func_host: Object, is_passable_func: String, opt_arg: Array) -> Array:
	var neighbor: Array = _new_CoordCalculator.get_neighbor(start_x, start_y,
			one_step)
	var min_distance: int = Game_PathFindingData.OBSTACLE
	var x: int
	var y: int
	var current_index: int = 0

	_new_ArrayHelper.filter_element(neighbor, func_host, is_passable_func,
			opt_arg)

	for i in neighbor.size():
		x = neighbor[i][0]
		y = neighbor[i][1]
		if _is_valid_distance(dungeon, x, y, Game_PathFindingData.OBSTACLE):
			if dungeon[x][y] < min_distance:
				min_distance = dungeon[x][y]
				_new_ArrayHelper.swap_element(neighbor, 0, i)
				current_index = 1
			elif dungeon[x][y] == min_distance:
				_new_ArrayHelper.swap_element(neighbor, current_index, i)
				current_index += 1

	neighbor.resize(current_index)
	return neighbor


# Create a distance map.
func get_map(dungeon: Dictionary, end_point: Array) -> Dictionary:
	if end_point.size() < 1:
		return dungeon

	var check: Array = end_point.pop_front()
	var neighbor: Array = _new_CoordCalculator.get_neighbor(
			check[0], check[1], 1)
	var x: int
	var y: int

	for i in neighbor:
		x = i[0]
		y = i[1]
		if dungeon[x][y] == Game_PathFindingData.UNKNOWN:
			dungeon[x][y] = _get_distance(dungeon, x, y)
			end_point.push_back(i)
	return get_map(dungeon, end_point)


func _get_distance(dungeon: Dictionary, center_x: int, center_y: int) -> int:
	var neighbor: Array = _new_CoordCalculator.get_neighbor(
			center_x, center_y, 1)
	var min_distance: int = Game_PathFindingData.OBSTACLE
	var x: int
	var y: int

	for i in neighbor:
		x = i[0]
		y = i[1]
		if _is_valid_distance(dungeon, x, y, min_distance):
			min_distance = dungeon[x][y]
	min_distance = min(min_distance + 1, Game_PathFindingData.OBSTACLE) as int
	return min_distance


func _is_valid_distance(dungeon: Dictionary, x: int, y: int,
		max_distance: int) -> bool:
	return (dungeon[x][y] < max_distance) \
			and (dungeon[x][y] > Game_PathFindingData.UNKNOWN)
