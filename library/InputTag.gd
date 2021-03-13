const MOVE_LEFT: String = "move_left"
const MOVE_RIGHT: String = "move_right"
const MOVE_UP: String = "move_up"
const MOVE_DOWN: String = "move_down"
const WAIT: String = "wait"

const RELOAD: String = "reload"
const REPLAY_DUNGEON: String = "replay_dungeon"
const QUIT: String = "quit"
const HELP: String = "help"
const COPY_SEED: String = "copy_seed"

const INIT_WORLD: String = "init_world"
const FORCE_RELOAD: String = "force_reload"
const ADD_TURN: String = "add_turn"
const FULLY_RESTORE_TURN: String = "fully_restore_turn"

const PAGE_DOWN: String = "page_down"
const PAGE_UP: String = "page_up"
const SCROLL_TO_TOP: String = "scroll_to_top"
const SCROLL_TO_BOTTOM: String = "scroll_to_bottom"
const NEXT_HELP: String = "next_help"
const PREVIOUS_HELP: String = "previous_help"

const DIRECTION_TO_COORD: Dictionary = {
	MOVE_UP: [0, -1],
	MOVE_DOWN: [0, 1],
	MOVE_LEFT: [-1, 0],
	MOVE_RIGHT: [1, 0],
}
