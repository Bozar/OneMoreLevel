extends Game_PCActionTemplate


const UP := 1
const DOWN := -1
const LEFT := 2
const RIGHT := -2

const INPUT_TO_DIRECT := {
	Game_InputTag.MOVE_UP: UP,
	Game_InputTag.MOVE_DOWN: DOWN,
	Game_InputTag.MOVE_LEFT: LEFT,
	Game_InputTag.MOVE_RIGHT: RIGHT,
}
const DIRECT_TO_SPRITE := {
	UP: Game_SpriteTypeTag.UP,
	DOWN: Game_SpriteTypeTag.DOWN,
	LEFT: Game_SpriteTypeTag.LEFT,
	RIGHT: Game_SpriteTypeTag.RIGHT,
}

var _move_direction := 0


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func switch_sprite() -> void:
	var pc := _ref_DungeonBoard.get_pc()

	_init_move_direction()
	_ref_SwitchSprite.set_sprite(pc, DIRECT_TO_SPRITE[_move_direction])


func _init_move_direction() -> void:
	var neighbor: Array
	var door_pos: Game_IntCoord
	var delta_x: int
	var delta_y: int

	if _move_direction != 0:
		return

	neighbor = Game_CoordCalculator.get_neighbor(
			_source_position.x, _source_position.y, 1)
	for i in neighbor:
		if _ref_DungeonBoard.has_building(i.x, i.y):
			door_pos = i
			break

	delta_x = door_pos.x - _source_position.x
	delta_y = door_pos.y - _source_position.y
	if delta_x > 0:
		_move_direction = UP
	elif delta_x < 0:
		_move_direction = DOWN
	elif delta_y > 0:
		_move_direction = RIGHT
	else:
		_move_direction = LEFT
