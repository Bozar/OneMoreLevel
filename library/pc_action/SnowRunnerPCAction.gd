extends Game_PCActionTemplate


var _spr_TruckGoods := preload("res://sprite/TruckGoods.tscn")

var _move_direction := 0
var _keep_moving := false
var _deliveries := 0
var _show_pc_digit := false
var _truck_slot := []


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func game_over(win: bool) -> void:
	_render_end_game(win)
	_switch_pc_sprite(true)


func switch_sprite() -> void:
	_init_move_direction()
	_init_truck()
	_switch_pc_sprite(false)


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

	right_direct = Game_StateTag.TURN_RIGHT[_move_direction]
	right_x = source_x + Game_StateTag.DIRECTION_TO_COORD[right_direct][0]
	right_y = source_y + Game_StateTag.DIRECTION_TO_COORD[right_direct][1]

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
	var new_direct: int = Game_InputTag.INPUT_TO_STATE[_input_direction]

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
	_switch_pc_sprite(not _show_pc_digit)
	_keep_moving = false
	end_turn = false


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
		_move_direction = Game_StateTag.UP
	elif delta_x < 0:
		_move_direction = Game_StateTag.DOWN
	elif delta_y > 0:
		_move_direction = Game_StateTag.RIGHT
	else:
		_move_direction = Game_StateTag.LEFT


func _init_truck() -> void:
	if _truck_slot.size() > 0:
		return

	var slot_shift: Array = Game_StateTag.DIRECTION_TO_COORD[
			_get_opposite_direct()]
	var x := _source_position.x
	var y := _source_position.y
	var new_sprite: Sprite

	for i in range(0, Game_SnowRunnerData.MAX_SLOT):
		if i == 0:
			_truck_slot.push_back(_ref_DungeonBoard.get_pc())
		else:
			x += slot_shift[0]
			y += slot_shift[1]
			new_sprite = _ref_CreateObject.create_and_fetch_actor(
					_spr_TruckGoods, Game_SubTag.TREASURE, x, y)
			_truck_slot.push_back(new_sprite)


func _is_opposite_direct(new_direct: int) -> bool:
	return _move_direction + new_direct == 0


func _is_same_direct(new_direct: int) -> bool:
	return _move_direction == new_direct


func _get_opposite_direct() -> int:
	return Game_StateTag.OPPOSITE_DIRECTION[_move_direction]


func _is_turn_right(new_direct: int) -> bool:
	return new_direct == Game_StateTag.TURN_RIGHT[_move_direction]


func _is_turn_left(new_direct: int) -> bool:
	return new_direct == Game_StateTag.TURN_LEFT[_move_direction]


func _can_turn_right() -> bool:
	var shift: Array = Game_StateTag.DIRECTION_TO_COORD[_move_direction]
	var x: int = _source_position.x + shift[0]
	var y: int = _source_position.y + shift[1]
	var target_ground := _ref_DungeonBoard.get_ground(x, y)

	return (target_ground != null) \
			and target_ground.is_in_group(Game_SubTag.CROSSROAD)


func _can_turn_left() -> bool:
	var source_ground := _ref_DungeonBoard.get_ground(
			_source_position.x, _source_position.y)
	var shift: Array = Game_StateTag.DIRECTION_TO_COORD[_get_opposite_direct()]
	var x: int = _source_position.x + shift[0]
	var y: int = _source_position.y + shift[1]
	var target_ground := _ref_DungeonBoard.get_ground(x, y)

	return source_ground.is_in_group(Game_SubTag.CROSSROAD) \
			and target_ground.is_in_group(Game_SubTag.CROSSROAD)


# TODO: A trap in the way is removed and consumes 1 turn.
func _move_truck() -> void:
	var self_pos: Game_IntCoord
	var new_pos := _target_position

	for i in _truck_slot:
		self_pos = Game_ConvertCoord.vector_to_coord(i.position)
		_ref_DungeonBoard.move_actor(self_pos.x, self_pos.y,
				new_pos.x, new_pos.y)
		new_pos = self_pos


func _switch_pc_sprite(show_digit: bool) -> void:
	var pc := _ref_DungeonBoard.get_pc()
	var digit: String = Game_SpriteTypeTag.convert_digit_to_tag(_deliveries)
	var direct: String = Game_StateTag.STATE_TO_SPRITE[_move_direction]

	if show_digit:
		_ref_SwitchSprite.set_sprite(pc, digit)
	else:
		_ref_SwitchSprite.set_sprite(pc, direct)
	_show_pc_digit = show_digit
