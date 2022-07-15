extends Game_AITemplate


const MAX_RETRY := 100


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action() -> void:
	var pos: Game_IntCoord

	match _ref_ObjectData.get_state(_self):
		Game_StateTag.DEFAULT:
			_start_wait()
		Game_StateTag.PASSIVE:
			_try_teleport()
		Game_StateTag.ACTIVE:
			_try_approach()

	pos = Game_ConvertCoord.sprite_to_coord(_self)
	_switch_sprite(pos.x, pos.y)


func _start_wait() -> void:
	var wait: int = _ref_RandomNumber.get_int(Game_FactoryData.MIN_WAIT,
			Game_FactoryData.MAX_WAIT)

	_ref_ObjectData.set_hit_point(_self, wait)
	_ref_ObjectData.set_state(_self, Game_StateTag.PASSIVE)


func _try_teleport() -> void:
	_ref_ObjectData.subtract_hit_point(_self, 1)
	if _ref_ObjectData.get_hit_point(_self) < 1:
		_teleport()
		_ref_ObjectData.set_state(_self, Game_StateTag.DEFAULT)


func _try_approach() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if _is_adjacent_to_pc():
		if _ref_ObjectData.verify_state(pc, Game_StateTag.PASSIVE):
			_teleport()
	else:
		_approach_pc([_pc_pos], 1, Game_FactoryData.SCP_STEP_COUNT)
	_ref_ObjectData.set_state(_self, Game_StateTag.DEFAULT)


func _stop_move() -> bool:
	return _is_adjacent_to_pc()


func _is_adjacent_to_pc() -> bool:
	return Game_CoordCalculator.is_in_range_xy(_self_pos.x, _self_pos.y,
			_pc_pos.x, _pc_pos.y, 1)


func _is_obstacle(x: int, y: int) -> bool:
	var building: Sprite = _ref_DungeonBoard.get_building_xy(x, y)

	if building == null:
		return false
	return not building.is_in_group(Game_SubTag.DOOR)


func _teleport() -> void:
	var target_pos: Game_IntCoord = _get_teleport_coord()
	_ref_DungeonBoard.move_actor(_self_pos, target_pos)


func _switch_sprite(x: int, y: int) -> void:
	var trap: Sprite = _ref_DungeonBoard.get_trap_xy(x, y)
	var new_type: String

	if trap == null:
		new_type = Game_SpriteTypeTag.DEFAULT
	elif trap.is_in_group(Game_SubTag.TREASURE):
		new_type = Game_SpriteTypeTag.ACTIVE
	# elif trap.is_in_group(Game_SubTag.RARE_TREASURE):
	else:
		new_type = Game_SpriteTypeTag.ACTIVE_1

	_ref_SwitchSprite.set_sprite(_self, new_type)


func _get_teleport_coord(retry := 0) -> Game_IntCoord:
	var pos := _ref_RandomNumber.get_dungeon_coord()

	if Game_ShadowCastFOV.is_in_sight(pos.x, pos.y):
		return _get_teleport_coord(retry)
	elif _ref_DungeonBoard.has_building(pos) and _is_not_door(pos):
		return _get_teleport_coord(retry)
	elif _ref_DungeonBoard.has_actor(pos):
		return _get_teleport_coord(retry)
	elif retry < MAX_RETRY:
		for i in Game_CoordCalculator.get_neighbor(pos,
				Game_FactoryData.SCP_GAP):
			if _ref_DungeonBoard.has_actor(pos):
				return _get_teleport_coord(retry + 1)
	return pos


func _is_not_door(coord: Game_IntCoord) -> bool:
	return not _ref_DungeonBoard.has_sprite_with_sub_tag(
			Game_MainTag.BUILDING, Game_SubTag.DOOR, coord)
