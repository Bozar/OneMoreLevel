extends Game_PCActionTemplate


var _spr_SoulFragment := preload("res://sprite/SoulFragment.tscn")

var _is_time_stop: bool = false
var _count_time_stop: int


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func switch_sprite() -> void:
	pass


func render_fov() -> void:
	_show_or_hide_trap()

	if _ref_GameSetting.get_show_full_map():
		_render_without_fog_of_war()
		return

	_new_ShadowCastFOV.set_field_of_view(
			Game_DungeonSize.MAX_X, Game_DungeonSize.MAX_Y,
			_source_position[0], _source_position[1], Game_NinjaData.PC_SIGHT,
			self, "_block_line_of_sight", [])

	for x in range(Game_DungeonSize.MAX_X):
		for y in range(Game_DungeonSize.MAX_Y):
			for i in Game_MainGroupTag.DUNGEON_OBJECT:
				if (i == Game_MainGroupTag.BUILDING) \
						or (i == Game_MainGroupTag.GROUND):
					_set_sprite_color_with_memory(x, y, i, "", true,
							_new_ShadowCastFOV, "is_in_sight")
				else:
					_set_sprite_color(x, y, i, "",
							_new_ShadowCastFOV, "is_in_sight")


func interact_with_trap() -> void:
	move()


func attack() -> void:
	var mirror : = _new_CoordCalculator.get_mirror_image(
			_source_position[0], _source_position[1],
			_target_position[0], _target_position[1])
	var pause_turn: bool

	if mirror.coord_in_dungeon:
		pause_turn = _try_hit_npc(_target_position[0], _target_position[1],
				mirror.x, mirror.y, false)
	else:
		pause_turn = _try_hit_npc(_target_position[0], _target_position[1],
				_target_position[0], _target_position[1], false)

	if pause_turn and (not _is_time_stop):
		_switch_time_stop(true)
	if _is_time_stop:
		render_fov()
	end_turn = not _is_time_stop


func move() -> void:
	var has_trap: bool = _ref_DungeonBoard.has_trap(
			_target_position[0], _target_position[1])
	var neighbor: Array = _new_CoordCalculator.get_neighbor(
			_target_position[0], _target_position[1], 1)
	var push_x: int
	var push_y: int
	var hit_npc: bool = false
	var pause_turn: bool

	_move_pc_sprite()

	for i in neighbor:
		if (i[0] == _source_position[0]) and (i[1] == _source_position[1]):
			continue
		elif i[0] == _source_position[0]:
			push_x = i[0]
			push_y = i[1] + (i[1] - _target_position[1])
		elif i[1] == _source_position[1]:
			push_x = i[0] + (i[0] - _target_position[0])
			push_y = i[1]
		elif i[0] == _target_position[0]:
			push_x = i[0] + (i[0] - _source_position[0])
			push_y = i[1]
		elif i[1] == _target_position[1]:
			push_x = i[0]
			push_y = i[1] + (i[1] - _source_position[1])

		if _try_hit_npc(i[0], i[1], push_x, push_y, true):
			hit_npc = true

	if _is_time_stop:
		if not (hit_npc or has_trap):
			_count_time_stop -= 1
		pause_turn = _count_time_stop > 0
	else:
		pause_turn = hit_npc

	if pause_turn:
		_source_position[0] = _target_position[0]
		_source_position[1] = _target_position[1]
		render_fov()
		if _is_time_stop:
			_update_counter()
		else:
			_switch_time_stop(true)
	else:
		_switch_time_stop(false)
		if _ref_DungeonBoard.get_npc().size() == 0:
			_ref_EndGame.player_win()
			return
	end_turn = not _is_time_stop


func wait() -> void:
	if _is_time_stop:
		_switch_time_stop(false)
		if _ref_DungeonBoard.get_npc().size() == 0:
			_ref_EndGame.player_win()
			return
	.wait()


func _block_line_of_sight(x: int, y: int, _opt_arg: Array) -> bool:
	return _ref_DungeonBoard.has_building(x, y) \
			or _ref_DungeonBoard.has_actor(x, y)


func _switch_time_stop(stop_time: bool) -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var passed_turn: int
	var subtract_time_stop: int

	_is_time_stop = stop_time
	if stop_time:
		_ref_ObjectData.set_hit_point(pc, 0)
		passed_turn = Game_CountDown.MAX_TURN - _ref_CountDown.get_count(true)
		subtract_time_stop = floor(passed_turn \
				/ Game_NinjaData.TIME_STOP_DIVISOR) as int
		_count_time_stop = Game_NinjaData.MAX_TIME_STOP - subtract_time_stop
		_update_counter()
	else:
		_ref_SwitchSprite.switch_sprite(pc, Game_SpriteTypeTag.DEFAULT)


func _update_counter() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var sprite_type: String = _new_SpriteTypeTag.convert_digit_to_tag(
			_count_time_stop)

	_ref_SwitchSprite.switch_sprite(pc, sprite_type)


func _try_hit_npc(hit_x: int, hit_y: int, push_x: int, push_y: int,
		push_npc: bool) -> bool:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var npc: Sprite = _ref_DungeonBoard.get_actor(hit_x, hit_y)
	var neighbor: Array

	if npc == null:
		return false
	elif _ref_ObjectData.verify_state(npc, Game_ObjectStateTag.DEFAULT):
		_ref_ObjectData.set_state(npc, Game_ObjectStateTag.PASSIVE)
		_ref_SwitchSprite.switch_sprite(npc, Game_SpriteTypeTag.PASSIVE)
		if _can_push_target(push_x, push_y):
			_ref_DungeonBoard.move_sprite(Game_MainGroupTag.ACTOR, hit_x, hit_y,
					push_x, push_y)
			return false
		return true

	_ref_RemoveObject.remove_actor(hit_x, hit_y)
	_ref_ObjectData.add_hit_point(pc, 1)

	if push_npc and _can_push_target(push_x, push_y):
		neighbor = _new_CoordCalculator.get_neighbor(push_x, push_y, 1, true)
	else:
		neighbor = [[hit_x, hit_y]]
	for i in neighbor:
		if _ref_DungeonBoard.has_actor(i[0], i[1]) \
				or _ref_DungeonBoard.has_building(i[0], i[1]):
			continue
		_ref_RemoveObject.remove_trap(i[0], i[1])
		_ref_CreateObject.create(_spr_SoulFragment,
				Game_MainGroupTag.TRAP, Game_SubGroupTag.TREASURE, i[0], i[1])

	return true


func _can_push_target(x: int, y: int) -> bool:
	if _new_CoordCalculator.is_inside_dungeon(x, y):
		return not (_ref_DungeonBoard.has_building(x, y) \
				or _ref_DungeonBoard.has_actor(x, y))
	return false


func _show_or_hide_trap() -> void:
	var find_traps: Array = _ref_DungeonBoard.get_sprites_by_tag(
			Game_MainGroupTag.TRAP)
	var pos: Array

	for i in find_traps:
		pos = _new_ConvertCoord.vector_to_array(i.position)
		i.visible = not _ref_DungeonBoard.has_actor(pos[0], pos[1])
