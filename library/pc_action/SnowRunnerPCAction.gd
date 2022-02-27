extends Game_PCActionTemplate


const UP := 1
const RIGHT := 2
const DOWN := -1
const LEFT := -2

const TURN_RIGHT := {
	UP: RIGHT,
	RIGHT: DOWN,
	DOWN: LEFT,
	LEFT: UP,
}
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
const DIRECT_TO_SHIFT := {
	UP: [0, -1],
	DOWN: [0, 1],
	LEFT: [-1, 0],
	RIGHT: [1, 0],
}

var _move_direction := 0
var _keep_moving := false


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func switch_sprite() -> void:
	var pc := _ref_DungeonBoard.get_pc()

	_init_move_direction()
	_ref_SwitchSprite.set_sprite(pc, DIRECT_TO_SPRITE[_move_direction])


func allow_input() -> bool:
	var source_x: int
	var source_y: int
	var target_x: int
	var target_y: int
	var right_direct: int
	var right_x: int
	var right_y: int
	var source_ground: Sprite
	var target_ground: Sprite
	var right_building: Sprite

	if not _keep_moving:
		return true

	source_x = _source_position.x
	source_y = _source_position.y

	set_target_position(_input_direction)
	target_x = _target_position.x
	target_y = _target_position.y

	right_direct = TURN_RIGHT[_move_direction]
	right_x = source_x + DIRECT_TO_SHIFT[right_direct][0]
	right_y = source_y + DIRECT_TO_SHIFT[right_direct][1]

	if _ref_DungeonBoard.has_building(target_x, target_y):
		_keep_moving = false
	else:
		source_ground = _ref_DungeonBoard.get_ground(source_x, source_y)
		target_ground = _ref_DungeonBoard.get_ground(target_x, target_y)
		right_building = _ref_DungeonBoard.get_building(right_x, right_y)
		if source_ground.is_in_group(Game_SubTag.CROSSROAD) \
				or target_ground.is_in_group(Game_SubTag.CROSSROAD):
			_keep_moving = false
		# TODO: Check empty slot.
		# TODO: Check door type: onload goods (close to border), offload goods,
		# door, passenger, final resting zone.
		# Set door types in progress.
		elif right_building.is_in_group(Game_SubTag.DOOR):
			_keep_moving = false
	return not _keep_moving


# is_trap() always returns false. Interact with trap in _move_truck().
func is_trap() -> bool:
	return false


func move() -> void:
	var new_direct: int = INPUT_TO_DIRECT[_input_direction]

	if _is_opposite_direct(new_direct):
		_keep_moving = false
		end_turn = false
	elif _is_same_direct(new_direct):
		_keep_moving = true
		end_turn = true
	elif (_is_turn_right(new_direct) and _can_turn_right()) \
			or (_is_turn_left(new_direct) and _can_turn_left()):
		_keep_moving = false
		end_turn = true
		_move_direction = new_direct
		# TODO: Cost 1 more turn if truck is fully loaded.

	if end_turn:
		_move_truck()


func attack() -> void:
	_keep_moving = false
	end_turn = false


# PC must be on a straight road.
# A door only has one neighboring floor.
func interact_with_building() -> void:
	pass


# Switch to a digit that shows the number of deliveries.
func wait() -> void:
	end_turn = true


func pass_turn() -> void:
	_move_truck()


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


func _is_opposite_direct(new_direct: int) -> bool:
	return _move_direction + new_direct == 0


func _is_same_direct(new_direct: int) -> bool:
	return _move_direction == new_direct


func _get_opposite_direct() -> int:
	return -_move_direction


func _is_turn_right(new_direct: int) -> bool:
	return new_direct == TURN_RIGHT[_move_direction]


func _is_turn_left(new_direct: int) -> bool:
	return _move_direction == TURN_RIGHT[new_direct]


func _can_turn_right() -> bool:
	var shift: Array = DIRECT_TO_SHIFT[_move_direction]
	var x: int = _source_position.x + shift[0]
	var y: int = _source_position.y + shift[1]
	var target_ground := _ref_DungeonBoard.get_ground(x, y)

	return (target_ground != null) \
			and target_ground.is_in_group(Game_SubTag.CROSSROAD)


func _can_turn_left() -> bool:
	var source_ground := _ref_DungeonBoard.get_ground(
			_source_position.x, _source_position.y)
	var shift: Array = DIRECT_TO_SHIFT[_get_opposite_direct()]
	var x: int = _source_position.x + shift[0]
	var y: int = _source_position.y + shift[1]
	var target_ground := _ref_DungeonBoard.get_ground(x, y)

	return source_ground.is_in_group(Game_SubTag.CROSSROAD) \
			and target_ground.is_in_group(Game_SubTag.CROSSROAD)


# A trap in the way is removed and consumes 1 turn.
func _move_truck() -> void:
	_move_pc_sprite()
