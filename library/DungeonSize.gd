const MAX_X: int = 21
const MAX_Y: int = 15

const CENTER_X: int = 10
const CENTER_Y: int = 7

const ARROW_MARGIN: int = 32


func is_inside_dungeon(x: int, y: int) -> bool:
	return (x > -1) and (x < MAX_X) and (y > -1) and (y < MAX_Y)


func filter_out_of_bound_coord(coords: Array) -> Array:
	var filtered: Array = []

	for xy in coords:
		if is_inside_dungeon(xy[0], xy[1]):
			filtered.push_back(xy)

	return filtered
