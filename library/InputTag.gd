class_name Game_InputTag
# InputTemplate._verify_input() requires a string tag.


const MOVE_LEFT := "move_left"
const MOVE_RIGHT := "move_right"
const MOVE_UP := "move_up"
const MOVE_DOWN := "move_down"
const WAIT := "wait"

const RELOAD := "reload"
const REPLAY_DUNGEON := "replay_dungeon"
const REPLAY_WORLD := "replay_world"
const QUIT := "quit"
const HELP := "help"
const COPY_SEED := "copy_seed"

const INIT_WORLD := "init_world"
const FORCE_RELOAD := "force_reload"
const ADD_TURN := "add_turn"
const FULLY_RESTORE_TURN := "fully_restore_turn"

const PAGE_DOWN := "page_down"
const PAGE_UP := "page_up"
const SCROLL_TO_TOP := "scroll_to_top"
const SCROLL_TO_BOTTOM := "scroll_to_bottom"
const NEXT_HELP := "next_help"
const PREVIOUS_HELP := "previous_help"

const ENTER_DEBUG := "enter_debug"
const LEAVE_DEBUG := "leave_debug"

const DIRECTION_TO_COORD := {
	MOVE_UP: [0, -1],
	MOVE_DOWN: [0, 1],
	MOVE_LEFT: [-1, 0],
	MOVE_RIGHT: [1, 0],
}

const MOVE_INPUT := [
	MOVE_LEFT,
	MOVE_RIGHT,
	MOVE_UP,
	MOVE_DOWN,
]

const INPUT_TO_SPRITE := {
	MOVE_UP: Game_SpriteTypeTag.UP,
	MOVE_DOWN: Game_SpriteTypeTag.DOWN,
	MOVE_LEFT: Game_SpriteTypeTag.LEFT,
	MOVE_RIGHT: Game_SpriteTypeTag.RIGHT,
}

const INPUT_TO_STATE := {
	MOVE_UP: Game_StateTag.UP,
	MOVE_DOWN: Game_StateTag.DOWN,
	MOVE_LEFT: Game_StateTag.LEFT,
	MOVE_RIGHT: Game_StateTag.RIGHT,
}
