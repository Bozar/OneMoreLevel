func get_range(source: Array, target: Array) -> int:
	var delta_x: int = abs(source[0] - target[0]) as int
	var delta_y: int = abs(source[1] - target[1]) as int

	return delta_x + delta_y


func is_inside_range(source: Array, target: Array, max_range: int) -> bool:
	return get_range(source, target) <= max_range


func get_neighbor(center: Array, distance: int) -> Array:
	var x: int = center[0]
	var y: int = center[1]
	var neighbor: Array = [
		[x - distance, y],
		[x + distance, y],
		[x, y - distance],
		[x, y + distance],
	]

	return neighbor
