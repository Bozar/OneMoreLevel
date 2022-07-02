class_name Game_StateTag


enum {
	DEFAULT,
	ACTIVE,
	PASSIVE,

	UP,
	DOWN,
	LEFT,
	RIGHT,
}

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

const TURN_RIGHT := {
	UP: RIGHT,
	RIGHT: DOWN,
	DOWN: LEFT,
	LEFT: UP,
}

const TURN_LEFT := {
	UP: LEFT,
	RIGHT: UP,
	DOWN: RIGHT,
	LEFT: DOWN,
}


static func is_opposite_direction(this_dir: int, that_dir: int) -> bool:
	if OPPOSITE_DIRECTION.has(this_dir) and OPPOSITE_DIRECTION.has(that_dir):
		return this_dir == OPPOSITE_DIRECTION[that_dir]
	return false
