const MAX_X: int = 21
const MAX_Y: int = 15

const CENTER_X: int = 10
const CENTER_Y: int = 7

const ARROW_MARGIN: int = 32


func is_inside_dungeon(x: int, y: int) -> bool:
	return (x > -1) and (x < MAX_X) and (y > -1) and (y < MAX_Y)
