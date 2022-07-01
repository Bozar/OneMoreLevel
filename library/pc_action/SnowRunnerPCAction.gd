extends Game_PCActionTemplate


enum SLOT {
	DEFAULT = 0,
	GOODS,
	ACTIVE_PASSENGER,
	PASSIVE_PASSENGER,
}

var _spr_DoorTruck := preload("res://sprite/DoorTruck.tscn")
var _spr_TruckSlot := preload("res://sprite/TruckSlot.tscn")

var _move_direction := 0
var _keep_moving := false
var _deliveries := 0
var _goods_in_garage := Game_SnowRunnerData.MAX_DELIVERY
var _show_pc_digit := false
var _truck_slot := []
var _door_coord := []
var _has_new_passenger := false


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func game_over(win: bool) -> void:
	_render_end_game(win)
	_switch_pc_sprite(not win, false)


func switch_sprite() -> void:
	_init_move_direction()
	_init_truck()
	_init_door_coord()
	_switch_pc_sprite(false, false)


func allow_input() -> bool:
	var source_x: int
	var source_y: int
	var target_x: int
	var target_y: int
	var right_direct: int
	var right_x: int
	var right_y: int
	var source_ground: Sprite
	var right_door: Sprite

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

	if _ref_DungeonBoard.has_building_xy(target_x, target_y):
		_keep_moving = false
	else:
		source_ground = _ref_DungeonBoard.get_ground_xy(source_x, source_y)
		right_door = _ref_DungeonBoard.get_building_xy(right_x, right_y)
		if source_ground.is_in_group(Game_SubTag.CROSSROAD):
			_keep_moving = false
		elif right_door.is_in_group(Game_SubTag.ONLOAD_GOODS):
			if _deliveries == Game_SnowRunnerData.MAX_DELIVERY:
				if _is_empty_loaded():
					_keep_moving = false
			elif _goods_in_garage > 0:
				if not _is_fully_loaded():
					_keep_moving = false
		elif right_door.is_in_group(Game_SubTag.OFFLOAD_GOODS):
			if _has_goods():
				_keep_moving = false
		elif right_door.is_in_group(Game_SubTag.DOOR):
			match _ref_ObjectData.get_state(right_door):
				Game_StateTag.DEFAULT:
					if _has_passenger():
						_keep_moving = false
				Game_StateTag.ACTIVE:
					if not _is_fully_loaded():
						_keep_moving = false
	return not _keep_moving


# is_trap() always returns false. Interact with trap in _move_truck().
func is_trap() -> bool:
	return false


func move() -> void:
	var new_direct: int = Game_InputTag.INPUT_TO_STATE[_input_direction]

	if _is_same_direct(new_direct):
		_keep_moving = true
		end_turn = true
		_active_passenger()
	elif _can_turn_right(new_direct) or _can_turn_left(new_direct):
		_keep_moving = false
		end_turn = true
		_move_direction = new_direct
		_turn_slowly()

	# end_turn is false by default.
	if end_turn:
		_move_truck()


func attack() -> void:
	_keep_moving = false
	end_turn = false


func interact_with_building() -> void:
	var door := _ref_DungeonBoard.get_building_xy(
			_target_position.x, _target_position.y)

	end_turn = false

	if door.is_in_group(Game_SubTag.ONLOAD_GOODS):
		if _deliveries == Game_SnowRunnerData.MAX_DELIVERY:
			if _is_empty_loaded():
				_ref_EndGame.player_win()
		elif _try_onload_goods():
			end_turn = true
	elif door.is_in_group(Game_SubTag.OFFLOAD_GOODS):
		if _try_offload_goods(door):
			end_turn = true
	elif door.is_in_group(Game_SubTag.DOOR):
		match _ref_ObjectData.get_state(door):
			Game_StateTag.ACTIVE:
				if _try_pick_up_passenger(door):
					end_turn = true
			Game_StateTag.DEFAULT:
				if _try_drop_off_passenger():
					end_turn = true


# Switch to a digit that shows the number of deliveries.
func wait() -> void:
	_switch_pc_sprite(not _show_pc_digit, true)
	_keep_moving = false
	end_turn = false


func pass_turn() -> void:
	_move_truck()


func _block_line_of_sight(x: int, y: int, _opt_arg: Array) -> bool:
	return _ref_DungeonBoard.has_building_xy(x, y)


func _init_move_direction() -> void:
	var neighbor: Array
	var door_pos: Game_IntCoord
	var delta_x: int
	var delta_y: int

	if _move_direction != 0:
		return

	neighbor = Game_CoordCalculator.get_neighbor_xy(
			_source_position.x, _source_position.y, 1)
	for i in neighbor:
		if _ref_DungeonBoard.has_building_xy(i.x, i.y):
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

	for _i in range(0, Game_SnowRunnerData.MAX_SLOT):
		x += slot_shift[0]
		y += slot_shift[1]
		new_sprite = _ref_CreateObject.create_and_fetch_actor(_spr_TruckSlot,
				Game_SubTag.TRUCK_SLOT, x, y)
		_truck_slot.push_back(new_sprite)


func _init_door_coord() -> void:
	if _door_coord.size() > 0:
		return

	var tags := [
		Game_SubTag.DOOR, Game_SubTag.OFFLOAD_GOODS, Game_SubTag.ONLOAD_GOODS,
	]
	var pos: Game_IntCoord

	for i in tags:
		for j in _ref_DungeonBoard.get_sprites_by_tag(i):
			pos = Game_ConvertCoord.vector_to_coord(j.position)
			_door_coord.push_back(pos)


func _is_same_direct(new_direct: int) -> bool:
	return _move_direction == new_direct


func _get_opposite_direct() -> int:
	return Game_StateTag.OPPOSITE_DIRECTION[_move_direction]


func _can_turn_right(new_direct: int) -> bool:
	# Verify input direction.
	if new_direct != Game_StateTag.TURN_RIGHT[_move_direction]:
		return false

	var shift: Array = Game_StateTag.DIRECTION_TO_COORD[_move_direction]
	var x: int = _source_position.x + shift[0]
	var y: int = _source_position.y + shift[1]
	var ground_ahead := _ref_DungeonBoard.get_ground_xy(x, y)

	# Verify traffic rule.
	return (ground_ahead != null) \
			and ground_ahead.is_in_group(Game_SubTag.CROSSROAD)


func _can_turn_left(new_direct: int) -> bool:
	# Verify input direction.
	if new_direct != Game_StateTag.TURN_LEFT[_move_direction]:
		return false

	var source_ground := _ref_DungeonBoard.get_ground_xy(
			_source_position.x, _source_position.y)
	var shift: Array = Game_StateTag.DIRECTION_TO_COORD[_get_opposite_direct()]
	var x: int = _source_position.x + shift[0]
	var y: int = _source_position.y + shift[1]
	var ground_behind := _ref_DungeonBoard.get_ground_xy(x, y)

	# Verify traffic rule.
	return source_ground.is_in_group(Game_SubTag.CROSSROAD) \
			and ground_behind.is_in_group(Game_SubTag.CROSSROAD)


func _is_fully_loaded() -> bool:
	for i in _truck_slot:
		if _ref_ObjectData.get_hit_point(i) == SLOT.DEFAULT:
			return false
	return true


func _is_empty_loaded() -> bool:
	for i in _truck_slot:
		if _ref_ObjectData.get_hit_point(i) != SLOT.DEFAULT:
			return false
	return true


func _has_goods() -> bool:
	for i in _truck_slot:
		if _ref_ObjectData.get_hit_point(i) == SLOT.GOODS:
			return true
	return false


func _has_passenger() -> bool:
	for i in _truck_slot:
		if _ref_ObjectData.get_hit_point(i) == SLOT.ACTIVE_PASSENGER:
			return true
	return false


func _move_truck() -> void:
	var self_pos: Game_IntCoord
	var new_pos := _target_position

	_clear_snow(new_pos.x, new_pos.y)
	_move_pc_sprite()

	new_pos = _source_position
	for i in _truck_slot:
		self_pos = Game_ConvertCoord.vector_to_coord(i.position)
		_ref_DungeonBoard.move_actor_xy(self_pos.x, self_pos.y,
				new_pos.x, new_pos.y)
		new_pos = self_pos


func _switch_pc_sprite(show_digit: bool, force_render_fov: bool) -> void:
	var pc := _ref_DungeonBoard.get_pc()
	var digit: String = Game_SpriteTypeTag.convert_digit_to_tag(_deliveries)
	var direct: String = Game_StateTag.STATE_TO_SPRITE[_move_direction]

	if show_digit:
		_ref_SwitchSprite.set_sprite(pc, digit)
		for i in _door_coord:
			_set_sprite_color(i.x, i.y, Game_MainTag.BUILDING, self,
					"_door_is_in_sight")
	else:
		_ref_SwitchSprite.set_sprite(pc, direct)
		if force_render_fov:
			for i in _door_coord:
				_set_sprite_color(i.x, i.y, Game_MainTag.BUILDING,
						Game_ShadowCastFOV, "is_in_sight")
	_show_pc_digit = show_digit


func _door_is_in_sight(_x: int, _y: int) -> bool:
	return true


func _try_onload_goods() -> bool:
	if _goods_in_garage > 0:
		for i in _truck_slot:
			if _ref_ObjectData.get_hit_point(i) == SLOT.DEFAULT:
				# Set truck slot.
				_ref_ObjectData.set_hit_point(i, SLOT.GOODS)
				_ref_SwitchSprite.set_sprite(i, Game_SpriteTypeTag.ACTIVE)
				# Update progress.
				_goods_in_garage -= 1
				return true
	return false


func _try_offload_goods(door: Sprite) -> bool:
	var pos := Game_ConvertCoord.vector_to_coord(door.position)

	for i in _truck_slot:
		if _ref_ObjectData.get_hit_point(i) == SLOT.GOODS:
			# Set truck slot.
			_ref_ObjectData.set_hit_point(i, SLOT.DEFAULT)
			_ref_SwitchSprite.set_sprite(i, Game_SpriteTypeTag.DEFAULT)
			# Replace sprite: offload -> door.
			_ref_RemoveObject.remove_building(pos.x, pos.y)
			_ref_CreateObject.create_building(_spr_DoorTruck, Game_SubTag.DOOR,
					pos.x, pos.y)
			# Update progress.
			_deliveries += 1
			_ref_CountDown.add_count(Game_SnowRunnerData.OFFLOAD_GOODS)
			return true
	return false


func _try_pick_up_passenger(door: Sprite) -> bool:
	for i in _truck_slot:
		if _ref_ObjectData.get_hit_point(i) == SLOT.DEFAULT:
			# Set truck slot.
			_ref_ObjectData.set_hit_point(i, SLOT.PASSIVE_PASSENGER)
			_ref_SwitchSprite.set_sprite(i, Game_SpriteTypeTag.PASSIVE_1)
			_has_new_passenger = true
			# Set door. Set sprite type and state in SnowRunnerProgress.
			_ref_ObjectData.set_hit_point(door,
					Game_SnowRunnerData.PASSENGER_LEAVE)
			# Update progress.
			_ref_CountDown.add_count(Game_SnowRunnerData.PICK_UP_PASSENGER)
			return true
	return false


func _try_drop_off_passenger() -> bool:
	for i in _truck_slot:
		if _ref_ObjectData.get_hit_point(i) == SLOT.ACTIVE_PASSENGER:
			# Set truck slot.
			_ref_ObjectData.set_hit_point(i, SLOT.DEFAULT)
			_ref_SwitchSprite.set_sprite(i, Game_SpriteTypeTag.DEFAULT)
			# Update progress.
			_ref_CountDown.add_count(Game_SnowRunnerData.DROP_OFF_PASSENGER)
			return true
	return false


func _active_passenger() -> void:
	if not _has_new_passenger:
		return

	_has_new_passenger = false
	for i in _truck_slot:
		if _ref_ObjectData.get_hit_point(i) == SLOT.PASSIVE_PASSENGER:
			_ref_ObjectData.set_hit_point(i, SLOT.ACTIVE_PASSENGER)
			_ref_SwitchSprite.set_sprite(i, Game_SpriteTypeTag.ACTIVE_1)


func _turn_slowly() -> void:
	if _is_fully_loaded():
		_ref_CountDown.subtract_count(Game_SnowRunnerData.GOODS_COST_TURN)


func _clear_snow(x: int, y: int) -> void:
	if _ref_DungeonBoard.has_trap_xy(x, y):
		_ref_RemoveObject.remove_trap(x, y)
		_ref_CountDown.subtract_count(Game_SnowRunnerData.SNOW_COST_TURN)
