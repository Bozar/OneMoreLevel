extends Game_AITemplate


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

	pos = Game_ConvertCoord.vector_to_coord(_self.position)
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
	return Game_CoordCalculator.is_inside_range(_self_pos.x, _self_pos.y,
			_pc_pos.x, _pc_pos.y, 1)


func _is_obstacle(x: int, y: int) -> bool:
	var building: Sprite = _ref_DungeonBoard.get_building(x, y)

	if building == null:
		return false
	return not building.is_in_group(Game_SubTag.DOOR)


func _teleport() -> void:
	var pos: Game_IntCoord

	while true:
		pos = _get_teleport_coord()
		if pos != null:
			break
	_ref_DungeonBoard.move_sprite(Game_MainTag.ACTOR,
			_self_pos.x, _self_pos.y, pos.x, pos.y)


func _switch_sprite(x: int, y: int) -> void:
	var trap: Sprite = _ref_DungeonBoard.get_trap(x, y)
	var new_type: String

	if trap == null:
		new_type = Game_SpriteTypeTag.DEFAULT
	elif trap.is_in_group(Game_SubTag.TREASURE):
		new_type = Game_SpriteTypeTag.ACTIVE
	elif trap.is_in_group(Game_SubTag.RARE_TREASURE):
		new_type = Game_SpriteTypeTag.ACTIVE_1

	_ref_SwitchSprite.switch_sprite(_self, new_type)


func _get_teleport_coord() -> Game_IntCoord:
	var x: int = _ref_RandomNumber.get_x_coord()
	var y: int = _ref_RandomNumber.get_y_coord()

	if Game_ShadowCastFOV.is_in_sight(x, y):
		return null
	elif _ref_DungeonBoard.has_building(x, y) \
			and (not _ref_DungeonBoard.has_sprite_with_sub_tag(Game_SubTag.DOOR,
					x, y)):
		return null
	else:
		for i in Game_CoordCalculator.get_neighbor(x, y,
				Game_FactoryData.SCP_GAP, true):
			if _ref_DungeonBoard.has_actor(i.x, i.y):
				return null
	return Game_IntCoord.new(x, y)
