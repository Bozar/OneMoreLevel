class_name Game_StateTag


const DEFAULT := "default"
const ACTIVE := "active"
const PASSIVE := "passive"

const UP := "up"
const DOWN := "down"
const LEFT := "left"
const RIGHT := "right"

const DIRECTION_TO_COORD := {
	UP: [0, -1],
	DOWN: [0, 1],
	LEFT: [-1, 0],
	RIGHT: [1, 0],
}

const VALID_DIRECTION := [UP, DOWN, LEFT, RIGHT]

const OPPOSITE_DIRECTION := {
	UP: DOWN,
	DOWN: UP,
	LEFT: RIGHT,
	RIGHT: LEFT,
}

const STATE_TO_SPRITE := {
	UP: Game_SpriteTypeTag.UP,
	DOWN: Game_SpriteTypeTag.DOWN,
	LEFT: Game_SpriteTypeTag.LEFT,
	RIGHT: Game_SpriteTypeTag.RIGHT,
}
