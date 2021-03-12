const DEFAULT: String = "default"
const ACTIVE: String = "active"
const PASSIVE: String = "passive"

const UP: String = "up"
const DOWN: String = "down"
const LEFT: String = "left"
const RIGHT: String = "right"

const DIRECTION_TO_COORD: Dictionary = {
	UP: [0, -1],
	DOWN: [0, 1],
	LEFT: [-1, 0],
	RIGHT: [1, 0],
}

const VALID_DIRECTION: Array = [UP, DOWN, LEFT, RIGHT]

const OPPOSITE_DIRECTION: Dictionary = {
	UP: DOWN,
	DOWN: UP,
	LEFT: RIGHT,
	RIGHT: LEFT,
}
